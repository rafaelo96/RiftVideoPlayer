import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var state: PlayerState

    @State private var isDraggingSlider = false
    @State private var dragSliderValue: Double = 0
    @State private var isSeekingPreview = false
    @State private var previewTime: Double = 0

    var body: some View {
        LiquidGlassPanel(cornerRadius: 18) {
            VStack(spacing: 12) {
                HStack {
                    Spacer(minLength: 24)
                    timeline
                    Spacer(minLength:                    24)
                }

                HStack(spacing: 16) {
                    playbackInfoCluster
                        .frame(maxWidth: .infinity, alignment: .leading)

                    transportControls
                        .frame(width: 154)

                    optionsBar
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: 980)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.isPlaying)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.playbackRate)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.fpsMode)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.interpolationMode)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.audioTracks.count)
    }

    // MARK: - Timeline with Chapter Markers

    private var timeline: some View {
        HStack(spacing: 10) {
            Text(state.formattedTime(isDraggingSlider ? dragSliderValue : state.currentTime))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .frame(width: 68, alignment: .leading)
                .foregroundStyle(.white.opacity(0.92))

            TimelineTrack(
                currentTime: isDraggingSlider ? dragSliderValue : state.currentTime,
                duration: max(state.duration, 1),
                onSeek: { value in
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        isDraggingSlider = true
                        dragSliderValue = value
                    }
                },
                onSeekEnd: { value in
                    state.seek(to: value)
                    isDraggingSlider = false
                }
            )

            Text(state.formattedTime(state.duration))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .frame(width: 68, alignment: .trailing)
                .foregroundStyle(.white.opacity(0.92))
        }
        .frame(maxWidth: 680)
    }

    // MARK: - Playback Info

    private var playbackInfoCluster: some View {
        HStack(spacing: 12) {
            volumeControl

            optionDivider

            fpsReadout

            // Seek preview indicator
            if isSeekingPreview {
                seekPreview
                    .frame(width: 80)
            }
        }
        .frame(minWidth: 210, alignment: .leading)
    }

    private var volumeControl: some View {
        HStack(spacing: 8) {
            GlassIconButton(
                systemName: volumeIcon,
                size: 14,
                action: { state.setVolume(state.volume > 0 ? 0 : 0.68) },
                accessibilityLabel: state.volume > 0 ? NSLocalizedString("Mute", comment: "") : NSLocalizedString("Unmute", comment: "")
            )

            Slider(
                value: Binding(
                    get: { state.volume },
                    set: { state.setVolume($0) }
                ),
                in: 0...1
            )
            .tint(accentColor)
            .frame(width: 82)
            .accessibilityLabel(NSLocalizedString("Volume", comment: ""))
        }
        .frame(width: 112, alignment: .leading)
    }

    private var fpsReadout: some View {
        HStack(spacing: 6) {
            Image(systemName: state.fpsMode.isActive
                ? "gauge.open.with.lines.needle.33percent"
                : "display")
                .font(.system(size: 11, weight: .semibold, design: .rounded))

            VStack(alignment: .leading, spacing: 1) {
                Text("\(String(format: "%.0f", state.displayRenderingFPS)) FPS")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .lineLimit(1)

                Text(framePlusStateTitle)
                    .font(.system(size: 8, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(state.fpsMode.isActive ? accentColor : .white.opacity(0.78))
        .frame(width: 76, alignment: .leading)
    }

    // MARK: - Transport Controls

    private var transportControls: some View {
        HStack(spacing: 18) {
            GlassIconButton(
                systemName: "gobackward.10",
                size: 15,
                action: { state.seek(by: -10) },
                accessibilityLabel: NSLocalizedString("Skip Back 10s", comment: "")
            )

            Button {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) {
                    state.togglePlay()
                }
            } label: {
                Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.white.opacity(0.22), .white.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            }
                    }
                    .shadow(color: Color(red: 0.36, green: 0.66, blue: 1.0).opacity(0.18), radius: 14, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.space, modifiers: [])
            .scaleEffect(state.isPlaying ? 1 : 0.96)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: state.isPlaying)
            .accessibilityLabel(state.isPlaying ? NSLocalizedString("Pause", comment: "") : NSLocalizedString("Play", comment: ""))

            GlassIconButton(
                systemName: "goforward.10",
                size: 15,
                action: { state.seek(by: 10) },
                accessibilityLabel: NSLocalizedString("Skip Forward 10s", comment: "")
            )
        }
    }

    // MARK: - Options Bar

    private var optionsBar: some View {
        HStack(spacing: 6) {
            interpolationButton
            speedButton
            visualButton

            if state.audioTracks.count > 1 {
                audioTrackButton
            }

            subtitleButton
        }
        .padding(5)
        .background(GlassCapsule())
    }

    // MARK: - Option Buttons

    private var interpolationButton: some View {
        Button {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.7)) {
                guard state.interpolationMode == .disabled else {
                    state.setInterpolationMode(.disabled)
                    return
                }
                state.setInterpolationMode(.motion2Intense)
            }
        } label: {
            glassPill(
                title: motionTitle,
                systemName: state.isFramePlusPreparing
                    ? "hourglass"
                    : (state.interpolationMode == .disabled
                        ? "rectangle.on.rectangle"
                        : "rectangle.on.rectangle.fill"),
                isActive: state.interpolationMode != .disabled,
                hint: NSLocalizedString("Frame Interpolation", comment: "")
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(NSLocalizedString("Frame Interpolation", comment: "")), \(state.interpolationMode == .disabled ? NSLocalizedString("Interpolation disabled", comment: "") : NSLocalizedString("Interpolation active", comment: ""))")
    }

    private var speedButton: some View {
        Button {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.7)) {
                state.cyclePlaybackRate()
            }
        } label: {
            glassPill(
                title: speedTitle,
                systemName: "gauge.with.dots.needle.33percent",
                isActive: state.playbackRate != 1.0,
                hint: NSLocalizedString("Playback Speed", comment: "")
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(NSLocalizedString("Playback Speed", comment: "")), \(speedTitle)")
    }

    private var visualButton: some View {
        Button {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.7)) {
                state.toggleVisualEnhancements()
            }
        } label: {
            glassPill(
                title: "Visual",
                systemName: "sparkle.magnifyingglass",
                isActive: state.visualEnhancementsEnabled,
                hint: NSLocalizedString("Visual Enhancements", comment: "")
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(NSLocalizedString("Visual Enhancements", comment: "")), \(state.visualEnhancementsEnabled ? NSLocalizedString("Visual on", comment: "") : NSLocalizedString("Visual off", comment: ""))")
    }

    private var audioTrackButton: some View {
        let activeLabel = state.audioTracks.indices.contains(state.selectedAudioTrackIndex)
            ? state.audioTracks[state.selectedAudioTrackIndex].label
            : "Audio"

        return Menu {
            ForEach(state.audioTracks) { track in
                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.7)) {
                        state.selectAudioTrack(track.id)
                    }
                } label: {
                    optionMenuRow(title: track.label, selected: track.id == state.selectedAudioTrackIndex)
                }
            }
        } label: {
            glassPill(
                title: activeLabel,
                systemName: "music.note.list",
                isActive: state.selectedAudioTrackIndex != 0,
                hint: NSLocalizedString("Audio Track", comment: "")
            )
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }

    private var subtitleButton: some View {
        let subtitleTracks = state.availableTracks.filter { $0.kind == .subtitle }

        return Menu {
            Button {
                withAnimation(.spring(response: 0.26, dampingFraction: 0.7)) {
                    state.selectPipelineTrack(nil)
                }
            } label: {
                optionMenuRow(title: "None", selected: state.selectedSubtitleTrack == nil)
            }

            ForEach(subtitleTracks) { track in
                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.7)) {
                        state.selectPipelineTrack(track)
                    }
                } label: {
                    optionMenuRow(title: track.label, selected: state.selectedSubtitleTrack == track)
                }
            }
        } label: {
            glassPill(
                title: state.selectedSubtitleTrack?.label ?? "Subs",
                systemName: "captions.bubble",
                isActive: state.selectedSubtitleTrack != nil,
                hint: NSLocalizedString("Subtitles", comment: "")
            )
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }

    // MARK: - Timeline with Chapter Support

    private var seekPreview: some View {
        VStack(spacing: 4) {
            Text("00:45")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))

            Rectangle()
                .fill(accentColor.opacity(0.4))
                .frame(width: 60, height: 3)
                .cornerRadius(1.5)
        }
    }

    // MARK: - Glass Pill

    private func glassPill(title: String, systemName: String, isActive: Bool, hint: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .frame(width: 13)

            Text(title)
                .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(isActive ? .white : .white.opacity(0.65))
        .frame(width: 94, height: 28)
        .background {
            Capsule()
                .fill(isActive
                    ? accentColor.opacity(0.22)
                    : .white.opacity(0.05))
        }
        .overlay {
            if isActive {
                Capsule()
                    .stroke(
                        LinearGradient(colors: [accentColor.opacity(0.50), accentColor.opacity(0.20)],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing),
                        lineWidth: 0.5)
            } else {
                Capsule()
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            }
        }
        .contentShape(Capsule())
        .help(hint)
    }

    // MARK: - Helpers

    private func optionMenuRow(title: String, selected: Bool) -> some View {
        Group {
            if selected {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }

    private var optionDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.12))
            .frame(width: 0.5, height: 22)
    }

    private var accentColor: Color {
        Color(red: 0.36, green: 0.66, blue: 1.0)
    }

    private var volumeIcon: String {
        switch state.volume {
        case 0: "speaker.slash.fill"
        case 0..<0.45: "speaker.wave.1.fill"
        default: "speaker.wave.2.fill"
        }
    }

    private var speedTitle: String {
        let value = Double(state.playbackRate)
        return value == 1 ? "1x" : String(format: "%.2gx", value)
    }

    private var motionTitle: String {
        state.isFramePlusPreparing ? "Frame⁺..." : "Frame⁺"
    }

    private var framePlusStateTitle: String {
        if state.isFramePlusPreparing { return NSLocalizedString("Preparing HQ", comment: "") }
        if state.isFramePlusPreRendered { return NSLocalizedString("60fps ready", comment: "") }
        if state.interpolationMode == .disabled { return NSLocalizedString("Disabled", comment: "") }
        return state.isArtificialInterpolationActive ? NSLocalizedString("Interpolating", comment: "") : NSLocalizedString("Waiting", comment: "")
    }
}

// MARK: - Timeline Track

struct TimelineTrack: View {
    let currentTime: Double
    let duration: Double
    let onSeek: (Double) -> Void
    let onSeekEnd: (Double) -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 4)
                .cornerRadius(2)

            Rectangle()
                .fill(accentColor)
                .frame(width: trackWidth, height: 4)
                .cornerRadius(2)

            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .frame(height: 16)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let w = max(0, value.translation.width + 340)
                            onSeek((w / 680) * duration)
                        }
                        .onEnded { value in
                            let w = max(0, value.translation.width + 340)
                            onSeekEnd((w / 680) * duration)
                        }
                )
        }
        .frame(maxWidth: 680)
        .frame(height: 16)
        .accessibilityLabel(NSLocalizedString("Timeline", comment: ""))
        .accessibilityValue("\(Int(currentTime / 60)):\(String(format: "%02d", Int(currentTime.truncatingRemainder(dividingBy: 60)))) de \(Int(duration / 60)):\(String(format: "%02d", Int(duration.truncatingRemainder(dividingBy: 60))))")
    }

    private var trackWidth: CGFloat {
        min(CGFloat(currentTime / duration) * 680, 680)
    }

    private var accentColor: Color {
        Color(red: 0.36, green: 0.66, blue: 1.0)
    }
}

// MARK: - GlassIconButton

struct GlassIconButton: View {
    var systemName: String
    var size: CGFloat = 15
    var action: () -> Void
    var accessibilityLabel: String?

    @State private var isPressed = false
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.55)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.55)) {
                    isPressed = false
                }
            }
            action()
        }) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(.white.opacity(isHovered ? 0.92 : 0.70))
                .frame(width: 32, height: 32)
                .background {
                    Circle()
                        .fill(.white.opacity(isHovered ? 0.08 : 0.03))
                }
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(isHovered ? 0.14 : 0.06), lineWidth: 0.5)
                }
                .scaleEffect(isPressed ? 0.88 : (isHovered ? 1.06 : 1))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel ?? labelFromSystemName)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }

    private var labelFromSystemName: String {
        switch systemName {
        case "gobackward.10": NSLocalizedString("Skip Back 10s", comment: "")
        case "goforward.10": NSLocalizedString("Skip Forward 10s", comment: "")
        case "speaker.slash.fill", "speaker.wave.1.fill", "speaker.wave.2.fill": NSLocalizedString("Mute", comment: "")
        default: systemName
        }
    }
}
