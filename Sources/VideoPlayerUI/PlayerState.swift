import AVFoundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class PlayerState: ObservableObject {
    // A single AVPlayer instance is shared between the video layer and SwiftUI controls.
    let player = AVPlayer()

    @Published var fileName = "Video.mp4"
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Double = 0.72
    @Published var playbackRate: Float = 1.0
    @Published var fpsMode: FPSMode = .off
    @Published var hasVideo = false
    @Published var statusMessage: String?

    private var timeObserver: Any?
    private var itemStatusObservation: NSKeyValueObservation?
    private var conversionProcess: Process?
    private var convertedVideoURL: URL?
    private let logURL = URL(fileURLWithPath: "/private/tmp/LiquidPlayer.log")
    private let rates: [Float] = [1.0, 1.25, 1.5, 2.0]
    private let containerFormatsNeedingConversion: Set<String> = ["mkv", "webm", "avi", "flv", "wmv", "ts", "m2ts"]

    init() {
        resetLog()
        log("PlayerState init")
        player.volume = Float(volume)
        addTimeObserver()

        if CommandLine.arguments.contains("--fps=60") {
            fpsMode = .sixty
            log("CLI fps mode forced to 60 FPS")
        } else if CommandLine.arguments.contains("--fps=30") {
            fpsMode = .thirty
            log("CLI fps mode forced to 30 FPS")
        }

        if let path = CommandLine.arguments.first(where: { !$0.hasPrefix("--") && $0 != CommandLine.arguments.first }) {
            log("CLI open requested: \(path)")
            Task { @MainActor in
                self.loadVideo(URL(fileURLWithPath: path))
            }
        }
    }

    func cleanup() {
        log("cleanup")
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }

        conversionProcess?.terminate()
        conversionProcess = nil
        itemStatusObservation = nil
        cleanupConvertedVideo()
    }

    func togglePlay() {
        guard player.currentItem != nil else { return }

        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.playImmediately(atRate: playbackRate)
            isPlaying = true
        }
    }

    func seek(to seconds: Double) {
        let boundedSeconds = max(0, min(seconds, duration))
        let time = CMTime(seconds: boundedSeconds, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = boundedSeconds
    }

    func seek(by delta: Double) {
        seek(to: currentTime + delta)
    }

    func setVolume(_ value: Double) {
        volume = max(0, min(value, 1))
        player.volume = Float(volume)
    }

    func cyclePlaybackRate() {
        // Cycles through the exact speed states requested by the UI spec.
        let currentIndex = rates.firstIndex(of: playbackRate) ?? 0
        playbackRate = rates[(currentIndex + 1) % rates.count]

        if isPlaying {
            player.rate = playbackRate
        }
    }

    func cycleFPSMode() {
        withAnimation(.easeInOut(duration: 0.22)) {
            fpsMode = fpsMode.next
        }
    }

    func openVideo() {
        let panel = NSOpenPanel()
        panel.title = "Open Video"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.data]
        panel.allowsOtherFileTypes = true

        guard panel.runModal() == .OK, let url = panel.url else { return }
        log("Open panel selected: \(url.path)")
        loadVideo(url)
    }

    func formattedTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "00:00" }
        let totalSeconds = max(0, Int(seconds.rounded(.down)))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }

    func loadVideo(_ url: URL) {
        log("loadVideo: \(url.path)")
        conversionProcess?.terminate()
        conversionProcess = nil
        cleanupConvertedVideo()

        if needsConversion(url) {
            convertAndLoadVideo(url)
            return
        }

        playVideo(url, displayName: url.lastPathComponent)
    }

    private func playVideo(_ url: URL, displayName: String) {
        log("playVideo: \(url.path), exists=\(FileManager.default.fileExists(atPath: url.path))")
        let item = AVPlayerItem(url: url)
        itemStatusObservation = item.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self else { return }

                switch item.status {
                case .unknown:
                    self.log("AVPlayerItem status=unknown")
                case .readyToPlay:
                    self.log("AVPlayerItem status=readyToPlay")
                    self.statusMessage = nil
                    self.player.playImmediately(atRate: self.playbackRate)
                    self.isPlaying = true
                case .failed:
                    self.log("AVPlayerItem status=failed error=\(item.error?.localizedDescription ?? "unknown")")
                    self.statusMessage = "No se pudo cargar el video convertido."
                    self.isPlaying = false
                @unknown default:
                    self.log("AVPlayerItem status=unknown default")
                }
            }
        }

        player.replaceCurrentItem(with: item)
        player.volume = Float(volume)

        fileName = displayName.isEmpty ? "Video.mp4" : displayName
        currentTime = 0
        duration = 0
        isPlaying = false
        hasVideo = true
        statusMessage = nil

        Task {
            let loadedDuration = try? await item.asset.load(.duration)
            let isPlayable = (try? await item.asset.load(.isPlayable)) ?? false
            await MainActor.run {
                duration = loadedDuration?.seconds.isFinite == true ? loadedDuration?.seconds ?? 0 : 0
                log("asset loaded: playable=\(isPlayable), duration=\(duration), status=\(item.status.rawValue)")
            }
        }
    }

    private func needsConversion(_ url: URL) -> Bool {
        containerFormatsNeedingConversion.contains(url.pathExtension.lowercased())
    }

    private func convertAndLoadVideo(_ sourceURL: URL) {
        log("convertAndLoadVideo: \(sourceURL.path)")
        guard let ffmpegURL = findFFmpeg() else {
            log("ffmpeg not found")
            statusMessage = "Para reproducir MKV instala ffmpeg: brew install ffmpeg"
            hasVideo = false
            return
        }

        statusMessage = "Preparando \(sourceURL.pathExtension.uppercased())..."
        hasVideo = false
        fileName = sourceURL.lastPathComponent

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("LiquidPlayer-\(UUID().uuidString).mp4")

        convertedVideoURL = outputURL
        log("conversion output: \(outputURL.path)")

        let remuxArguments = [
            "-hide_banner",
            "-loglevel", "error",
            "-i", sourceURL.path,
            "-map", "0:v:0",
            "-map", "0:a?",
            "-sn",
            "-dn",
            "-c", "copy",
            "-y", outputURL.path
        ]

        runFFmpeg(ffmpegURL, arguments: remuxArguments) { [weak self] success in
            guard let self else { return }
            self.log("remux success=\(success)")

            if success {
                self.playVideo(outputURL, displayName: sourceURL.lastPathComponent)
                return
            }

            self.statusMessage = "Convirtiendo audio..."
            let audioOnlyArguments = [
                "-hide_banner",
                "-loglevel", "error",
                "-i", sourceURL.path,
                "-map", "0:v:0",
                "-map", "0:a?",
                "-sn",
                "-dn",
                "-c:v", "copy",
                "-c:a", "aac",
                "-b:a", "192k",
                "-y", outputURL.path
            ]

            self.runFFmpeg(ffmpegURL, arguments: audioOnlyArguments) { [weak self] success in
                guard let self else { return }
                self.log("audio-only success=\(success)")

                if success {
                    self.playVideo(outputURL, displayName: sourceURL.lastPathComponent)
                    return
                }

                self.statusMessage = "Convirtiendo video..."
                let transcodeArguments = [
                    "-hide_banner",
                    "-loglevel", "error",
                    "-i", sourceURL.path,
                    "-map", "0:v:0",
                    "-map", "0:a?",
                    "-sn",
                    "-dn",
                    "-c:v", "h264_videotoolbox",
                    "-b:v", "8M",
                    "-pix_fmt", "yuv420p",
                    "-c:a", "aac",
                    "-b:a", "192k",
                    "-y", outputURL.path
                ]

                self.runFFmpeg(ffmpegURL, arguments: transcodeArguments) { [weak self] success in
                    guard let self else { return }
                    self.log("videotoolbox transcode success=\(success)")

                    if success {
                        self.playVideo(outputURL, displayName: sourceURL.lastPathComponent)
                    } else {
                        self.statusMessage = "Convirtiendo compatible..."
                        let softwareArguments = [
                            "-hide_banner",
                            "-loglevel", "error",
                            "-i", sourceURL.path,
                            "-map", "0:v:0",
                            "-map", "0:a?",
                            "-sn",
                            "-dn",
                            "-c:v", "libx264",
                            "-preset", "veryfast",
                            "-crf", "20",
                            "-pix_fmt", "yuv420p",
                            "-c:a", "aac",
                            "-b:a", "192k",
                            "-y", outputURL.path
                        ]

                        self.runFFmpeg(ffmpegURL, arguments: softwareArguments) { [weak self] success in
                            guard let self else { return }
                            self.log("software transcode success=\(success)")

                            if success {
                                self.playVideo(outputURL, displayName: sourceURL.lastPathComponent)
                            } else {
                                self.statusMessage = "No se pudo convertir este MKV."
                                self.hasVideo = false
                                self.cleanupConvertedVideo()
                            }
                        }
                    }
                }
            }
        }
    }

    private func runFFmpeg(_ executableURL: URL, arguments: [String], completion: @escaping @MainActor (Bool) -> Void) {
        log("ffmpeg start: \(arguments.joined(separator: " "))")
        let process = Process()
        process.executableURL = executableURL
        process.arguments = ["-nostdin"] + arguments
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        let errorPipe = Pipe()
        process.standardError = errorPipe
        conversionProcess = process
        if let outputPath = arguments.last {
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak process] in
            guard let process else {
                Task { @MainActor in completion(false) }
                return
            }

            do {
                try process.run()
                var tick = 0

                while process.isRunning {
                    Thread.sleep(forTimeInterval: 1)
                    tick += 1

                    let outputPath = arguments.last ?? ""
                    let fileSize = (try? FileManager.default.attributesOfItem(atPath: outputPath)[.size] as? NSNumber)?.int64Value ?? 0
                    let elapsedSeconds = tick

                    Task { @MainActor in
                        self.log("ffmpeg running \(elapsedSeconds)s, outputBytes=\(fileSize)")
                        self.statusMessage = "Preparando video... \(elapsedSeconds)s"
                    }
                }

                let success = process.terminationStatus == 0
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let outputText = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let errorText = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                Task { @MainActor in
                    self.conversionProcess = nil
                    self.log("ffmpeg exit=\(process.terminationStatus), success=\(success), stdout=\(outputText), stderr=\(errorText)")
                    completion(success)
                }
            } catch {
                Task { @MainActor in
                    self.conversionProcess = nil
                    self.log("ffmpeg run error: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }

    private func findFFmpeg() -> URL? {
        [
            "/opt/homebrew/bin/ffmpeg",
            "/usr/local/bin/ffmpeg",
            "/usr/bin/ffmpeg"
        ]
        .map(URL.init(fileURLWithPath:))
        .first { FileManager.default.isExecutableFile(atPath: $0.path) }
    }

    private func cleanupConvertedVideo() {
        guard let convertedVideoURL else { return }
        log("cleanupConvertedVideo: \(convertedVideoURL.path)")
        try? FileManager.default.removeItem(at: convertedVideoURL)
        self.convertedVideoURL = nil
    }

    private func resetLog() {
        try? "Liquid Player log\n".write(to: logURL, atomically: true, encoding: .utf8)
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

    private func addTimeObserver() {
        // Keeps sliders, labels, and play state synchronized with AVPlayer playback.
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)

        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self else { return }

                self.currentTime = time.seconds.isFinite ? time.seconds : 0

                if let itemDuration = self.player.currentItem?.duration.seconds,
                   itemDuration.isFinite,
                   itemDuration > 0 {
                    self.duration = itemDuration
                }

                self.isPlaying = self.player.timeControlStatus == .playing
            }
        }
    }

}

enum FPSMode: String, CaseIterable {
    case off = "FPS Off"
    case thirty = "30 FPS"
    case sixty = "60 FPS"

    var next: FPSMode {
        switch self {
        case .off: .thirty
        case .thirty: .sixty
        case .sixty: .off
        }
    }

    var isActive: Bool {
        self != .off
    }

    var framesPerSecond: Int? {
        switch self {
        case .off: nil
        case .thirty: 30
        case .sixty: 60
        }
    }

    var renderFramesPerSecond: Int {
        switch self {
        case .off, .sixty: 60
        case .thirty: 30
        }
    }
}
