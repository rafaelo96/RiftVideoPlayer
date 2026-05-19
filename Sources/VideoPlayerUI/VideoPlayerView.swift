import AVFoundation
import CoreImage
import MetalKit
import SwiftUI

struct VideoPlayerView: NSViewRepresentable {
    let player: AVPlayer
    let fpsMode: FPSMode

    func makeNSView(context: Context) -> MetalVideoView {
        let view = MetalVideoView()
        context.coordinator.configure(view: view, player: player, fpsMode: fpsMode)
        return view
    }

    func updateNSView(_ nsView: MetalVideoView, context: Context) {
        context.coordinator.configure(view: nsView, player: player, fpsMode: fpsMode)
    }

    func makeCoordinator() -> MetalVideoRenderer {
        MetalVideoRenderer()
    }
}

final class MetalVideoView: MTKView {
    init() {
        let metalDevice = MTLCreateSystemDefaultDevice()
        super.init(frame: .zero, device: metalDevice)

        framebufferOnly = false
        enableSetNeedsDisplay = false
        isPaused = false
        preferredFramesPerSecond = 60
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.01, green: 0.02, blue: 0.05, alpha: 1)
        layer?.isOpaque = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class MetalVideoRenderer: NSObject, MTKViewDelegate {
    private weak var player: AVPlayer?
    private weak var attachedItem: AVPlayerItem?
    private var fpsMode: FPSMode = .off
    private var videoOutput: AVPlayerItemVideoOutput?
    private var commandQueue: MTLCommandQueue?
    private var ciContext: CIContext?
    private var lastFrame: CVPixelBuffer?
    private var currentFrame: CVPixelBuffer?
    private var lastFrameTime = CMTime.invalid
    private var currentFrameTime = CMTime.invalid
    private let opticalFlowEngine = OpticalFlowEngine()
    private let logURL = URL(fileURLWithPath: "/private/tmp/LiquidPlayer.log")
    private var hasLoggedFirstFrame = false
    private var lastConfiguredFPSMode: FPSMode?
    private var metricsStartTime = CACurrentMediaTime()
    private var drawnFrameCount = 0
    private var sourceFrameCount = 0
    private var interpolatedFrameCount = 0
    private var passthroughFrameCount = 0
    private var opticalFlowFrameCount = 0
    private var blendFallbackFrameCount = 0
    private var minInterpolationAmount = 1.0
    private var maxInterpolationAmount = 0.0
    private var sumInterpolationAmount = 0.0
    private var sourceFrameIndex = 0
    private var memcDisabledUntil = 0.0
    private var previousAverageLuma: Double?
    private var averageLumaAccumulator = 0.0
    private var averageLumaSamples = 0
    private let memcIntensity = MEMCIntensity.high
    private let performanceMode = MEMCPerformanceMode.balanced
    private lazy var memcKernel: CIKernel? = {
        CIKernel(source:
            """
            kernel vec4 memcInterpolate(sampler previousFrame, sampler currentFrame, sampler flowMap, float amount, float maxMotion, float warpStrength, float memcMix, float flowScale, float occlusionThreshold) {
                vec2 dc = destCoord();
                vec4 flowSample = sample(flowMap, samplerTransform(flowMap, dc));
                vec2 motion = flowSample.xy * flowScale * warpStrength;
                float motionLength = length(motion);

                if (motionLength > maxMotion) {
                    motion = motion * (maxMotion / motionLength);
                }

                vec2 previousCoord = dc - motion * amount;
                vec2 currentCoord = dc + motion * (1.0 - amount);

                vec4 previousColor = sample(previousFrame, samplerTransform(previousFrame, previousCoord));
                vec4 currentColor = sample(currentFrame, samplerTransform(currentFrame, currentCoord));
                vec4 previousOriginal = sample(previousFrame, samplerTransform(previousFrame, dc));
                vec4 currentOriginal = sample(currentFrame, samplerTransform(currentFrame, dc));
                vec4 warped = mix(previousColor, currentColor, amount);
                vec4 dissolved = mix(previousOriginal, currentOriginal, amount);
                float disagreement = distance(previousColor.rgb, currentColor.rgb);
                float confidence = 1.0 - smoothstep(occlusionThreshold * 0.55, occlusionThreshold, disagreement);
                float finalMix = memcMix * confidence;

                return mix(dissolved, warped, finalMix);
            }
            """
        )
    }()

    @MainActor
    func configure(view: MetalVideoView, player: AVPlayer, fpsMode: FPSMode) {
        self.player = player

        if lastConfiguredFPSMode != fpsMode {
            log("renderer: fpsMode changed to \(fpsMode.rawValue), targetDrawFPS=\(fpsMode.renderFramesPerSecond)")
            resetMetrics()
            lastConfiguredFPSMode = fpsMode
        }

        self.fpsMode = fpsMode

        view.preferredFramesPerSecond = fpsMode.renderFramesPerSecond
        view.delegate = self

        if commandQueue == nil, let device = view.device {
            commandQueue = device.makeCommandQueue()
            ciContext = CIContext(mtlDevice: device, options: [.cacheIntermediates: false])
        }

        attachOutputIfNeeded(to: player.currentItem)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let commandBuffer = commandQueue?.makeCommandBuffer(),
              let ciContext,
              let output = videoOutput else {
            return
        }

        let hostTime = CACurrentMediaTime()
        let itemTime = output.itemTime(forHostTime: hostTime)

        if output.hasNewPixelBuffer(forItemTime: itemTime) {
            var displayTime = CMTime.invalid
            guard let pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: &displayTime) else {
                log("renderer: has new frame but copyPixelBuffer returned nil at \(itemTime.seconds)")
                return
            }

            lastFrame = currentFrame
            lastFrameTime = currentFrameTime
            currentFrame = pixelBuffer
            currentFrameTime = displayTime.isValid ? displayTime : itemTime
            sourceFrameCount += 1
            sourceFrameIndex += 1
            detectSceneChangeIfNeeded(pixelBuffer)

            if !hasLoggedFirstFrame {
                hasLoggedFirstFrame = true
                log("renderer: first frame \(CVPixelBufferGetWidth(pixelBuffer))x\(CVPixelBufferGetHeight(pixelBuffer)), time=\(currentFrameTime.seconds)")
            }

            if fpsMode == .sixty, let lastFrame, sourceFrameIndex.isMultiple(of: performanceMode.flowFrameInterval) {
                opticalFlowEngine.update(previousFrame: lastFrame, currentFrame: pixelBuffer)
            }
        }

        guard let image = imageForCurrentMode(output: output, itemTime: itemTime) else { return }
        drawnFrameCount += 1
        logMetricsIfNeeded()

        let fittedImage = aspectFill(image, in: view.drawableSize)
        let destinationBounds = CGRect(origin: .zero, size: view.drawableSize)

        ciContext.render(
            fittedImage,
            to: drawable.texture,
            commandBuffer: commandBuffer,
            bounds: destinationBounds,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func attachOutputIfNeeded(to item: AVPlayerItem?) {
        guard attachedItem !== item else { return }

        if let videoOutput, let attachedItem {
            attachedItem.remove(videoOutput)
        }

        attachedItem = item
        lastFrame = nil
        currentFrame = nil
        lastFrameTime = .invalid
        currentFrameTime = .invalid
        sourceFrameIndex = 0
        memcDisabledUntil = 0
        previousAverageLuma = nil
        hasLoggedFirstFrame = false
        resetMetrics()

        guard let item else {
            videoOutput = nil
            log("renderer: detached output")
            return
        }

        let attributes: [String: any Sendable] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]

        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        output.requestNotificationOfMediaDataChange(withAdvanceInterval: 0.03)
        item.add(output)
        videoOutput = output
        log("renderer: attached AVPlayerItemVideoOutput")
    }

    private func imageForCurrentMode(output: AVPlayerItemVideoOutput, itemTime: CMTime) -> CIImage? {
        guard let currentFrame else { return nil }

        switch fpsMode {
        case .off, .thirty:
            passthroughFrameCount += 1
            return CIImage(cvPixelBuffer: currentFrame)

        case .sixty:
            if let lastFrame,
               lastFrameTime.isValid,
               currentFrameTime.isValid {
                let amount = interpolationAmount(for: itemTime)
                recordInterpolationAmount(amount)
                return blendedImage(first: lastFrame, second: currentFrame, amount: amount)
            }

            passthroughFrameCount += 1
            return CIImage(cvPixelBuffer: currentFrame)
        }
    }

    private func interpolationAmount(for itemTime: CMTime) -> Double {
        let frameDuration = currentFrameTime.seconds - lastFrameTime.seconds

        guard frameDuration.isFinite, frameDuration > 0 else {
            return 1
        }

        // MEMC-style rendering needs a tiny delay so the renderer has frame A and frame B.
        let delayedTime = itemTime.seconds - frameDuration
        let rawAmount = (delayedTime - lastFrameTime.seconds) / frameDuration
        return min(max(rawAmount, 0), 1)
    }

    private func recordInterpolationAmount(_ amount: Double) {
        interpolatedFrameCount += 1
        minInterpolationAmount = min(minInterpolationAmount, amount)
        maxInterpolationAmount = max(maxInterpolationAmount, amount)
        sumInterpolationAmount += amount
    }

    private func resetMetrics() {
        metricsStartTime = CACurrentMediaTime()
        drawnFrameCount = 0
        sourceFrameCount = 0
        interpolatedFrameCount = 0
        passthroughFrameCount = 0
        opticalFlowFrameCount = 0
        blendFallbackFrameCount = 0
        minInterpolationAmount = 1.0
        maxInterpolationAmount = 0.0
        sumInterpolationAmount = 0.0
    }

    private func logMetricsIfNeeded() {
        let now = CACurrentMediaTime()
        let elapsed = now - metricsStartTime

        guard elapsed >= 1 else { return }

        let drawFPS = Double(drawnFrameCount) / elapsed
        let sourceFPS = Double(sourceFrameCount) / elapsed
        let averageAlpha = interpolatedFrameCount > 0 ? sumInterpolationAmount / Double(interpolatedFrameCount) : 0
        let frameDelta = currentFrameTime.isValid && lastFrameTime.isValid
            ? currentFrameTime.seconds - lastFrameTime.seconds
            : 0

        log(
            String(
                format: "fps metrics: mode=%@ memc=%@/%@ drawFPS=%.1f sourceFPS=%.1f interpolated=%d opticalFlow=%d blendFallback=%d passthrough=%d alpha[min=%.2f avg=%.2f max=%.2f] lumaAvg=%.3f sourceFrameDelta=%.4f",
                fpsMode.rawValue,
                memcIntensity.rawValue,
                performanceMode.rawValue,
                drawFPS,
                sourceFPS,
                interpolatedFrameCount,
                opticalFlowFrameCount,
                blendFallbackFrameCount,
                passthroughFrameCount,
                minInterpolationAmount == 1.0 && interpolatedFrameCount == 0 ? 0 : minInterpolationAmount,
                averageAlpha,
                maxInterpolationAmount,
                averageLumaSamples > 0 ? averageLumaAccumulator / Double(averageLumaSamples) : 0,
                frameDelta
            )
        )

        if fpsMode == .sixty, drawFPS < 55 {
            memcDisabledUntil = now + 1.5
            log(String(format: "memc adaptive: disabled optical-flow warp for 1.5s because drawFPS=%.1f", drawFPS))
        }

        resetMetrics()
    }

    private func blendedImage(first: CVPixelBuffer, second: CVPixelBuffer, amount: Double) -> CIImage {
        let firstImage = CIImage(cvPixelBuffer: first)
        let secondImage = CIImage(cvPixelBuffer: second)

        if CACurrentMediaTime() >= memcDisabledUntil,
           let flow = opticalFlowEngine.snapshotFlow(maxAge: performanceMode.maxFlowAge),
           let memcImage = opticalFlowImage(previousImage: firstImage, currentImage: secondImage, flow: flow, amount: amount) {
            opticalFlowFrameCount += 1
            return memcImage
        }

        blendFallbackFrameCount += 1

        return firstImage
            .applyingFilter("CIDissolveTransition", parameters: [
                kCIInputTargetImageKey: secondImage,
                kCIInputTimeKey: amount
            ])
            .cropped(to: secondImage.extent)
    }

    private func opticalFlowImage(previousImage: CIImage, currentImage: CIImage, flow: OpticalFlowSnapshot, amount: Double) -> CIImage? {
        guard let memcKernel else { return nil }

        let flowImage = CIImage(cvPixelBuffer: flow.pixelBuffer)

        return memcKernel.apply(
            extent: currentImage.extent,
            roiCallback: { _, rect in
                rect.insetBy(dx: -96, dy: -96)
            },
            arguments: [
                previousImage,
                currentImage,
                flowImage,
                Float(amount),
                Float(memcIntensity.maxMotion),
                Float(memcIntensity.warpStrength),
                Float(memcIntensity.mix),
                flow.vectorScale,
                Float(memcIntensity.occlusionThreshold)
            ]
        )?.cropped(to: currentImage.extent)
    }

    private func detectSceneChangeIfNeeded(_ pixelBuffer: CVPixelBuffer) {
        guard sourceFrameIndex.isMultiple(of: 6) else { return }

        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let extent = image.extent
        guard let averageFilter = CIFilter(name: "CIAreaAverage") else { return }
        averageFilter.setValue(image, forKey: kCIInputImageKey)
        averageFilter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)

        guard let outputImage = averageFilter.outputImage else { return }

        var pixel = [UInt8](repeating: 0, count: 4)
        ciContext?.render(
            outputImage,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        let luma = (0.2126 * Double(pixel[0]) + 0.7152 * Double(pixel[1]) + 0.0722 * Double(pixel[2])) / 255.0
        averageLumaAccumulator += luma
        averageLumaSamples += 1

        if let previousAverageLuma, abs(luma - previousAverageLuma) > 0.20 {
            memcDisabledUntil = CACurrentMediaTime() + 0.8
            log(String(format: "memc adaptive: scene/cut detected lumaDelta=%.3f, using blend fallback", abs(luma - previousAverageLuma)))
        }

        previousAverageLuma = luma
    }

    private func aspectFill(_ image: CIImage, in drawableSize: CGSize) -> CIImage {
        guard image.extent.width > 0, image.extent.height > 0, drawableSize.width > 0, drawableSize.height > 0 else {
            return image
        }

        let scale = max(drawableSize.width / image.extent.width, drawableSize.height / image.extent.height)
        let scaledWidth = image.extent.width * scale
        let scaledHeight = image.extent.height * scale
        let x = (drawableSize.width - scaledWidth) * 0.5
        let y = (drawableSize.height - scaledHeight) * 0.5

        return image
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            .transformed(by: CGAffineTransform(translationX: x, y: y))
            .cropped(to: CGRect(origin: .zero, size: drawableSize))
    }

    private func log(_ message: String) {
        let line = "[\(Date())] \(message)\n"
        print(line, terminator: "")

        guard let data = line.data(using: .utf8) else { return }

        if FileManager.default.fileExists(atPath: logURL.path),
           let handle = try? FileHandle(forWritingTo: logURL) {
            try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
            try? handle.close()
        } else {
            try? data.write(to: logURL)
        }
    }
}

private enum MEMCIntensity: String {
    case high = "Alto"

    var maxMotion: Double {
        switch self {
        case .high: 22
        }
    }

    var warpStrength: Double {
        switch self {
        case .high: 0.54
        }
    }

    var mix: Double {
        switch self {
        case .high: 0.62
        }
    }

    var occlusionThreshold: Double {
        switch self {
        case .high: 0.42
        }
    }
}

private enum MEMCPerformanceMode: String {
    case balanced = "Balance"

    var flowFrameInterval: Int {
        switch self {
        case .balanced: 3
        }
    }

    var maxFlowAge: TimeInterval {
        switch self {
        case .balanced: 0.22
        }
    }
}
