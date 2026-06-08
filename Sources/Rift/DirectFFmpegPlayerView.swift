import AVFoundation
import AppKit
import SwiftUI
@preconcurrency import KSPlayer

@MainActor
protocol DirectFFmpegPlaybackControlling: AnyObject {
    func play()
    func pause()
    func seek(to seconds: Double)
    func setVolume(_ value: Double)
    func setPlaybackRate(_ rate: Float)
    func selectAudioTrack(_ index: Int)
    func selectSubtitleTrack(_ index: Int?)
    func shutdown()
}

struct DirectFFmpegPlayerView: NSViewRepresentable {
    let url: URL
    @ObservedObject var state: PlayerState

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    func makeNSView(context: Context) -> DirectFFmpegHostView {
        let view = DirectFFmpegHostView()
        context.coordinator.attach(view)
        view.open(url, options: context.coordinator.options())
        state.attachDirectPlaybackController(context.coordinator)
        return view
    }

    func updateNSView(_ view: DirectFFmpegHostView, context: Context) {
        context.coordinator.attach(view)
        state.attachDirectPlaybackController(context.coordinator)

        if view.currentURL != url {
            view.open(url, options: context.coordinator.options())
        }

        context.coordinator.setVolume(state.volume)
        context.coordinator.setPlaybackRate(state.playbackRate)
    }

    static func dismantleNSView(_ view: DirectFFmpegHostView, coordinator: Coordinator) {
        coordinator.shutdown()
        coordinator.state?.detachDirectPlaybackController(coordinator)
        view.shutdown()
    }
}

final class DirectFFmpegHostView: VideoPlayerView {
    var currentURL: URL?
    var onStateChanged: ((KSPlayerState, KSPlayerLayer) -> Void)?
    var onTimeChanged: ((TimeInterval, TimeInterval, KSPlayerLayer) -> Void)?
    var onFinished: ((Error?, KSPlayerLayer?) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        hideBuiltInChrome()
    }

    private func hideBuiltInChrome() {
        toolBar.isHidden = true
        topMaskView.isHidden = true
        bottomMaskView.isHidden = true
        replayButton.isHidden = true
        lockButton.isHidden = true
        loadingIndector.isHidden = true
        seekToView.isHidden = true
        speedTipLabel.isHidden = true
    }

    func open(_ url: URL, options: KSOptions) {
        currentURL = url

        let previousFirstPlayerType = KSOptions.firstPlayerType
        let previousSecondPlayerType = KSOptions.secondPlayerType
        KSOptions.firstPlayerType = KSMEPlayer.self
        KSOptions.secondPlayerType = nil
        set(url: url, options: options)
        KSOptions.firstPlayerType = previousFirstPlayerType
        KSOptions.secondPlayerType = previousSecondPlayerType
    }

    func shutdown() {
        playerLayer?.stop()
        playerLayer = nil
        currentURL = nil
    }

    override func player(layer: KSPlayerLayer, state: KSPlayerState) {
        super.player(layer: layer, state: state)
        onStateChanged?(state, layer)
    }

    override func player(layer: KSPlayerLayer, currentTime: TimeInterval, totalTime: TimeInterval) {
        super.player(layer: layer, currentTime: currentTime, totalTime: totalTime)
        onTimeChanged?(currentTime, totalTime, layer)
    }

    override func player(layer: KSPlayerLayer, finish error: Error?) {
        super.player(layer: layer, finish: error)
        onFinished?(error, layer)
    }
}

extension DirectFFmpegPlayerView {
    @MainActor
    final class Coordinator: NSObject, DirectFFmpegPlaybackControlling {
        weak var state: PlayerState?
        private weak var view: DirectFFmpegHostView?
        private var audioTracksByIndex: [Int: any MediaPlayerTrack] = [:]
        private var subtitleTracksByIndex: [Int: any MediaPlayerTrack] = [:]

        init(state: PlayerState) {
            self.state = state
        }

        func attach(_ view: DirectFFmpegHostView) {
            self.view = view
            view.onStateChanged = { [weak self] playerState, layer in
                self?.handleState(playerState, layer: layer)
            }
            view.onTimeChanged = { [weak self] currentTime, totalTime, layer in
                self?.handleTime(currentTime, totalTime: totalTime, layer: layer)
            }
            view.onFinished = { [weak self] error, _ in
                self?.handleFinish(error)
            }
        }

        func options() -> KSOptions {
            let options = KSOptions()
            options.automaticWindowResize = false
            options.registerRemoteControll = false
            options.hardwareDecode = true
            options.isSecondOpen = true
            options.preferredForwardBufferDuration = 0.05
            options.maxBufferDuration = 4
            options.probesize = 2 * 1024 * 1024
            options.maxAnalyzeDuration = 700_000
            return options
        }

        func play() {
            view?.playerLayer?.play()
        }

        func pause() {
            view?.playerLayer?.pause()
        }

        func seek(to seconds: Double) {
            view?.playerLayer?.seek(time: max(0, seconds), autoPlay: state?.isPlaying == true) { [weak self] finished in
                guard finished else { return }
                self?.state?.currentTime = max(0, seconds)
            }
        }

        func setVolume(_ value: Double) {
            view?.playerLayer?.player.playbackVolume = Float(max(0, min(value, 1)))
        }

        func setPlaybackRate(_ rate: Float) {
            view?.playerLayer?.player.playbackRate = rate
        }

        func selectAudioTrack(_ index: Int) {
            guard let track = audioTracksByIndex[index] else { return }
            view?.playerLayer?.player.select(track: track)
            state?.selectedAudioTrackIndex = index
            state?.selectedAudioTrack = state?.availableTracks.first { $0.kind == .audio && $0.index == index }
        }

        func selectSubtitleTrack(_ index: Int?) {
            let player = view?.playerLayer?.player
            for (trackIndex, track) in subtitleTracksByIndex {
                track.isEnabled = trackIndex == index
            }

            if let index, let track = subtitleTracksByIndex[index] {
                player?.select(track: track)
                state?.selectedSubtitleTrack = state?.availableTracks.first { $0.kind == .subtitle && $0.index == index }
            } else {
                state?.selectedSubtitleTrack = nil
            }
        }

        func shutdown() {
            view?.shutdown()
        }

        private func handleState(_ playerState: KSPlayerState, layer: KSPlayerLayer) {
            switch playerState {
            case .initialized, .preparing:
                state?.statusMessage = "Abriendo MKV directo..."
                state?.isPlaying = false
            case .readyToPlay:
                syncTracks(from: layer)
                state?.duration = finite(layer.player.duration)
                state?.statusMessage = nil
                state?.hasVideo = true
                state?.isPlaying = false
                setVolume(state?.volume ?? 0.72)
                setPlaybackRate(state?.playbackRate ?? 1.0)
            case .buffering:
                state?.isPlaying = true
                state?.statusMessage = "Cargando..."
            case .bufferFinished:
                state?.isPlaying = true
                state?.statusMessage = nil
            case .paused:
                state?.isPlaying = false
            case .playedToTheEnd:
                state?.isPlaying = false
                state?.currentTime = state?.duration ?? 0
            case .error:
                state?.isPlaying = false
                state?.directPlaybackDidFail("No se pudo abrir el MKV directo.")
            }
        }

        private func handleTime(_ currentTime: TimeInterval, totalTime: TimeInterval, layer: KSPlayerLayer) {
            state?.currentTime = finite(currentTime)
            state?.duration = finite(totalTime)
            if let displayFPS = layer.player.dynamicInfo?.displayFPS, displayFPS > 0 {
                state?.currentRenderingFPS = displayFPS
            } else if let sourceFrameRate = state?.sourceFrameRate, sourceFrameRate > 0 {
                state?.currentRenderingFPS = sourceFrameRate
            }
        }

        private func handleFinish(_ error: Error?) {
            state?.isPlaying = false
            if let error {
                state?.directPlaybackDidFail(error.localizedDescription)
            }
        }

        private func syncTracks(from layer: KSPlayerLayer) {
            let player = layer.player
            let audioTracks = player.tracks(mediaType: .audio)
            let subtitleTracks = player.tracks(mediaType: .subtitle)

            audioTracksByIndex = Dictionary(uniqueKeysWithValues: audioTracks.enumerated().map { ($0.offset, $0.element) })
            subtitleTracksByIndex = Dictionary(uniqueKeysWithValues: subtitleTracks.enumerated().map { ($0.offset, $0.element) })

            let audioModels = audioTracks.enumerated().map { index, track in
                PlayerState.AudioTrack(
                    id: index,
                    label: label(prefix: "Audio", index: index, track: track),
                    language: track.languageCode
                )
            }

            let mediaTracks = audioTracks.enumerated().map { index, track in
                MediaTrack(
                    id: "direct-audio-\(index)",
                    kind: .audio,
                    index: index,
                    label: label(prefix: "Audio", index: index, track: track),
                    languageCode: track.languageCode
                )
            } + subtitleTracks.enumerated().map { index, track in
                MediaTrack(
                    id: "direct-subtitle-\(index)",
                    kind: .subtitle,
                    index: index,
                    label: label(prefix: "Subtitulo", index: index, track: track),
                    languageCode: track.languageCode
                )
            }

            let selectedAudioIndex = audioTracks.firstIndex { $0.isEnabled } ?? 0
            let selectedSubtitleIndex = subtitleTracks.firstIndex { $0.isEnabled }
            let selectedSubtitleTrack = selectedSubtitleIndex.flatMap { index in
                mediaTracks.first { $0.kind == .subtitle && $0.index == index }
            }

            state?.directPlaybackDidLoadTracks(
                audioTracks: audioModels,
                availableTracks: mediaTracks,
                selectedAudioIndex: selectedAudioIndex,
                selectedSubtitleTrack: selectedSubtitleTrack,
                nominalFrameRate: player.nominalFrameRate
            )
        }

        private func finite(_ value: Double) -> Double {
            value.isFinite ? max(0, value) : 0
        }

        private func label(prefix: String, index: Int, track: any MediaPlayerTrack) -> String {
            let trimmedName = track.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedName.isEmpty, trimmedName.lowercased() != "unknown" {
                return "\(prefix) \(index + 1) · \(trimmedName)"
            }

            if let language = track.language, !language.isEmpty {
                return "\(prefix) \(index + 1) · \(language)"
            }

            if let languageCode = track.languageCode, !languageCode.isEmpty, languageCode != "und" {
                let language = Locale.current.localizedString(forLanguageCode: languageCode) ?? languageCode.uppercased()
                return "\(prefix) \(index + 1) · \(language)"
            }

            return "\(prefix) \(index + 1)"
        }
    }
}
