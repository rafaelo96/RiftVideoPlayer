import AVFoundation
import AppKit
import SwiftUI

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

    private var timeObserver: Any?
    private let rates: [Float] = [1.0, 1.25, 1.5, 2.0]

    init() {
        player.volume = Float(volume)
        addTimeObserver()
    }

    func cleanup() {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
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
        panel.allowedContentTypes = [.movie, .video, .mpeg4Movie, .quickTimeMovie]

        guard panel.runModal() == .OK, let url = panel.url else { return }
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
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.volume = Float(volume)

        fileName = url.lastPathComponent.isEmpty ? "Video.mp4" : url.lastPathComponent
        currentTime = 0
        duration = 0
        isPlaying = false
        hasVideo = true

        Task {
            let loadedDuration = try? await item.asset.load(.duration)
            await MainActor.run {
                duration = loadedDuration?.seconds.isFinite == true ? loadedDuration?.seconds ?? 0 : 0
            }
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
