import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var state: PlayerState

    @State private var isDraggingSlider = false
    @State private var dragSliderValue: Double = 0

    var body: some View {
        LiquidGlassPanel(cornerRadius: 18, blendsWithWindow: true) {
            VStack(spacing: 8) {
                HStack {
                    Spacer(minLength: 24)
                    timeline
                    Spacer(minLength: 24)
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
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 11)
        }
        .frame(maxWidth: 980)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.isPlaying)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.playbackRate)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.fpsMode)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.interpolationMode)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: state.audioTracks.count)
    }

    // MARK: - Timeline

    private var timeline: some View {
        HStack(spacing: 10) {
            Text(state.formattedTime(isDraggingSlider ? dragSliderValue : state.currentTime))
                .frame(width: 62, alignment: .leading)

            Slider(
                value: Binding(
                    get: { isDraggingSlider ? dragSliderValue : state.currentTime },
                    set: { dragSliderValue = $0 }
                ),
                in: 0...max(state.duration, 1),
                onEditingChanged: { editing in
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        isDraggingSlider = editing
                    }
                    if editing {
                        dragSliderValue = state.currentTime
                    } else {
                        state.seek(to: dragSliderValue)
                    }
                }
            )
            .tint(accentColor)

            Text(state.formattedTime(state.duration))
                .frame(width: 62, alignment: .trailing)
        }
        .frame(maxWidth: 680)
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.white.opacity(0.86))
    }

    // MARK: - Playback Info

    private var playbackInfoCluster: some View {
        HStack(spacing: 12) {
            volumeControl
            optionDivider
            fpsReadout
        }
        .frame(minWidth: 210, alignment: .leading)
    }

    private var volumeControl: some View {
        HStack(spacing: 8) {
            GlassIconButton(systemName: volumeIcon, size: 14, action: {
                state.setVolume(state.volume > 0 ? 0 : 0.68)
            })

            Slider(
                value: Binding(
                    get: { state.volume },
                    set: { state.setVolume($0) }
                ),
                in: 0...1
            )
            .tint(accentColor)
            .frame(width: 82)
        }
        .frame(width: 112, alignment: .leading)
    }

    private var fpsReadout: some View {
        HStack(spacing: 6) {
            Image(systemName: state.fpsMode.isActive
                ? "gauge.open.with.lines.needle.33percent"
                : "display")
                .font(.system(size: 11, weight: .semibold))

            VStack(alignment: .leading, spacing: 1) {
                Text("\(String(format: "%.0f", state.displayRenderingFPS)) FPS")
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)

                Text(framePlusStateTitle)
                    .font(.system(size: 8, weight: .medium))
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
            GlassIconButton(systemName: "gobackward.10", size: 15, action: {
                state.seek(by: -10)
            })

            Button {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) {
                    state.togglePlay()
                }
            } label: {
                Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(.white.opacity(0.10))
                            .overlay {
                                Circle()
                                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                            }
                    }
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.space, modifiers: [])
            .scaleEffect(state.isPlaying ? 1 : 0.96)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: state.isPlaying)

            GlassIconButton(systemName: "goforward.10", size: 15, action: {
                state.seek(by: 10)
            })
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
                hint: "Interpolación de frames"
            )
        }
        .buttonStyle(.plain)
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
                hint: "Velocidad de reproducción"
            )
        }
        .buttonStyle(.plain)
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
                hint: "Mejoras visuales"
            )
        }
        .buttonStyle(.plain)
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
                hint: "Pista de audio"
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
                hint: "Subtítulos"
            )
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }

    // MARK: - Glass Pill

    private func glassPill(title: String, systemName: String, isActive: Bool, hint: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 13)

            Text(title)
                .font(.system(size: 10.5, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(isActive ? .white : .white.opacity(0.65))
        .frame(width: 94, height: 28)
        .background {
            Capsule()
                .fill(isActive ? accentColor.opacity(0.18) : .white.opacity(0.04))
        }
        .overlay {
            Capsule()
                .strokeBorder(
                    isActive ? accentColor.opacity(0.35) : .white.opacity(0.08),
                    lineWidth: 0.5
                )
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
        if state.isFramePlusPreparing { return "Preparando HQ" }
        if state.isFramePlusPreRendered { return "60fps listo" }
        if state.interpolationMode == .disabled { return "Desactivado" }
        return state.isArtificialInterpolationActive ? "Interpolando" : "Esperando"
    }
}

// MARK: - GlassIconButton

struct GlassIconButton: View {
    var systemName: String
    var size: CGFloat = 15
    var action: () -> Void

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
                        .overlay {
                            Circle()
                                .strokeBorder(.white.opacity(isHovered ? 0.12 : 0.06), lineWidth: 0.5)
                        }
                }
                .scaleEffect(isPressed ? 0.88 : (isHovered ? 1.06 : 1))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
