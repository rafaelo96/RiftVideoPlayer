import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var state: PlayerState

    var body: some View {
        // Floating control island, always visible for this iteration.
        LiquidGlassPanel(cornerRadius: 17) {
            VStack(spacing: 6) {
                HStack(alignment: .center, spacing: 13) {
                    volumeControl

                    Spacer(minLength: 12)

                    transportControls

                    Spacer(minLength: 12)

                    speedAndFPS
                }

                timeline
            }
            .padding(.horizontal, 16)
            .padding(.top, 7)
            .padding(.bottom, 9)
        }
        .frame(maxWidth: 800)
        .animation(.easeInOut(duration: 0.22), value: state.isPlaying)
        .animation(.easeInOut(duration: 0.22), value: state.playbackRate)
        .animation(.easeInOut(duration: 0.22), value: state.fpsMode)
    }

    private var timeline: some View {
        // Current time, scrubber, and total duration stay on one compact row.
        HStack(spacing: 11) {
            Text(state.formattedTime(state.currentTime))
                .frame(width: 43, alignment: .leading)

            Slider(
                value: Binding(
                    get: { state.currentTime },
                    set: { state.seek(to: $0) }
                ),
                in: 0...max(state.duration, 1)
            )
            .tint(Color(red: 0.48, green: 0.36, blue: 1.0))

            Text(state.formattedTime(state.duration))
                .frame(width: 43, alignment: .trailing)
        }
        .font(.system(size: 13, weight: .regular, design: .default))
        .foregroundStyle(.white.opacity(0.9))
    }

    private var volumeControl: some View {
        HStack(spacing: 10) {
            Image(systemName: volumeIcon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .frame(width: 21)

            Slider(
                value: Binding(
                    get: { state.volume },
                    set: { state.setVolume($0) }
                ),
                in: 0...1
            )
            .tint(Color(red: 0.50, green: 0.37, blue: 1.0))
            .frame(width: 88)
        }
        .frame(width: 119, alignment: .leading)
    }

    private var transportControls: some View {
        // The transport cluster intentionally contains only back, play/pause, and forward.
        HStack(spacing: 24) {
            LiquidGlassButton(systemName: "backward.end.fill", size: .largeIcon) {
                state.seek(by: -10)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    state.togglePlay()
                }
            } label: {
                Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.18),
                                                Color(red: 0.40, green: 0.34, blue: 1.0).opacity(0.22)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.24), lineWidth: 1)
                            }
                    }
                    .shadow(color: Color(red: 0.38, green: 0.34, blue: 1.0).opacity(0.26), radius: 10, x: 0, y: 5)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.space, modifiers: [])

            LiquidGlassButton(systemName: "forward.end.fill", size: .largeIcon) {
                state.seek(by: 10)
            }
        }
    }

    private var speedAndFPS: some View {
        HStack(spacing: 8) {
            LiquidGlassButton(
                title: speedTitle,
                subtitle: "Velocidad",
                systemName: "speedometer",
                isActive: state.playbackRate != 1.0,
                size: .metric
            ) {
                state.cyclePlaybackRate()
            }

            LiquidGlassButton(
                title: fpsTitle,
                subtitle: "FPS",
                systemName: "rectangle.inset.filled",
                isActive: state.fpsMode.isActive,
                size: .metric
            ) {
                state.cycleFPSMode()
            }
        }
        .frame(width: 176, alignment: .trailing)
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

        if value == 1 {
            return "1x"
        }

        return String(format: "%.2gx", value)
    }

    private var fpsTitle: String {
        switch state.fpsMode {
        case .off: "Off"
        case .thirty: "30 FPS"
        case .sixty: "60 FPS"
        }
    }
}
