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

    @MainActor
    func configure(view: MetalVideoView, player: AVPlayer, fpsMode: FPSMode) {
        self.player = player
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
                return
            }

            lastFrame = currentFrame
            lastFrameTime = currentFrameTime
            currentFrame = pixelBuffer
            currentFrameTime = displayTime.isValid ? displayTime : itemTime

            if fpsMode == .sixty, let lastFrame {
                opticalFlowEngine.update(previousFrame: lastFrame, currentFrame: pixelBuffer)
            }
        }

        guard let image = imageForCurrentMode(output: output, itemTime: itemTime) else { return }
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

        guard let item else {
            videoOutput = nil
            return
        }

        let attributes: [String: any Sendable] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]

        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        item.add(output)
        videoOutput = output
    }

    private func imageForCurrentMode(output: AVPlayerItemVideoOutput, itemTime: CMTime) -> CIImage? {
        guard let currentFrame else { return nil }

        switch fpsMode {
        case .off, .thirty:
            return CIImage(cvPixelBuffer: currentFrame)

        case .sixty:
            if let lastFrame,
               lastFrameTime.isValid,
               currentFrameTime.isValid {
                let amount = interpolationAmount(for: itemTime)
                return blendedImage(first: lastFrame, second: currentFrame, amount: amount)
            }

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

    private func blendedImage(first: CVPixelBuffer, second: CVPixelBuffer, amount: Double) -> CIImage {
        let firstImage = CIImage(cvPixelBuffer: first)
        let secondImage = CIImage(cvPixelBuffer: second)

        return firstImage
            .applyingFilter("CIDissolveTransition", parameters: [
                kCIInputTargetImageKey: secondImage,
                kCIInputTimeKey: amount
            ])
            .cropped(to: secondImage.extent)
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
}
