@preconcurrency import AVFoundation
@preconcurrency import Vision

final class OpticalFlowEngine: @unchecked Sendable {
    private let queue = DispatchQueue(label: "liquid-player.optical-flow", qos: .userInitiated)
    private var isProcessing = false
    private(set) var latestFlow: CVPixelBuffer?

    func update(previousFrame: CVPixelBuffer, currentFrame: CVPixelBuffer) {
        guard !isProcessing,
              CVPixelBufferGetWidth(previousFrame) == CVPixelBufferGetWidth(currentFrame),
              CVPixelBufferGetHeight(previousFrame) == CVPixelBufferGetHeight(currentFrame) else {
            return
        }

        isProcessing = true

        queue.async { [weak self] in
            guard let self else { return }
            defer { self.isProcessing = false }

            let handler = VNImageRequestHandler(cvPixelBuffer: previousFrame, options: [:])
            let request = VNGenerateOpticalFlowRequest(targetedCVPixelBuffer: currentFrame, options: [:])
            request.computationAccuracy = .low
            request.outputPixelFormat = kCVPixelFormatType_TwoComponent16Half

            do {
                try handler.perform([request])
                self.latestFlow = request.results?.first?.pixelBuffer
            } catch {
                self.latestFlow = nil
            }
        }
    }
}
