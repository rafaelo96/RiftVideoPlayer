import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var state = PlayerState()
    @State private var isDropTargeted = false

    var body: some View {
        ZStack {
            appBackdrop

            if state.hasVideo {
                VideoPlayerView(player: state.player, fpsMode: state.fpsMode)
                    .ignoresSafeArea()
                    .overlay(videoVignette)
                    .transition(.opacity.combined(with: .scale(scale: 1.01)))
            }

            if !state.hasVideo {
                openVideoPrompt
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }

            VStack {
                Spacer()

                ZStack {
                    controlsContrastField

                    PlayerControlsView(state: state)
                }
                .padding(.horizontal, 84)
                .padding(.bottom, 34)
            }
        }
        .background(appBackdrop)
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDropTargeted, perform: handleDrop)
        .animation(.easeInOut(duration: 0.24), value: state.hasVideo)
        .animation(.easeInOut(duration: 0.18), value: isDropTargeted)
        .onDisappear {
            state.cleanup()
        }
    }

    private var appBackdrop: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.015, green: 0.045, blue: 0.105),
                    Color(red: 0.025, green: 0.090, blue: 0.210),
                    Color(red: 0.010, green: 0.030, blue: 0.075)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color(red: 0.18, green: 0.38, blue: 0.82).opacity(0.34),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 80,
                endRadius: 740
            )

            RadialGradient(
                colors: [
                    Color(red: 0.04, green: 0.18, blue: 0.46).opacity(0.50),
                    .clear
                ],
                center: .center,
                startRadius: 140,
                endRadius: 780
            )
        }
        .ignoresSafeArea()
    }

    private var openVideoPrompt: some View {
        Button {
            state.openVideo()
        } label: {
            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 27, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 27, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.14), .blue.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 27, style: .continuous)
                                .stroke(.white.opacity(isDropTargeted ? 0.42 : 0.18), lineWidth: 1)
                        }

                    Image(systemName: "folder")
                        .font(.system(size: 56, weight: .regular))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.70, green: 0.62, blue: 1.0),
                                    Color(red: 0.38, green: 0.36, blue: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .frame(width: 142, height: 130)
                .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 18)

                VStack(spacing: 12) {
                    Text("Abrir video")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.96))

                    Text("Arrastra un archivo de video aqui\no haz clic para seleccionar")
                        .font(.system(size: 19, weight: .regular))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundStyle(.white.opacity(0.66))

                    if let statusMessage = state.statusMessage {
                        Text(statusMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(red: 0.62, green: 0.58, blue: 1.0))
                            .padding(.top, 4)
                    }
                }
            }
            .scaleEffect(isDropTargeted ? 1.04 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.bottom, 130)
    }

    private var videoVignette: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.18),
                .clear,
                .black.opacity(0.55)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var controlsContrastField: some View {
        LinearGradient(
            colors: [
                .clear,
                Color(red: 0.04, green: 0.05, blue: 0.18).opacity(0.26),
                .black.opacity(0.16)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(maxWidth: 880, maxHeight: 120)
        .blur(radius: 18)
        .allowsHitTesting(false)
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) else {
            return false
        }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            let droppedURL: URL?

            if let data = item as? Data {
                droppedURL = URL(dataRepresentation: data, relativeTo: nil)
            } else if let url = item as? URL {
                droppedURL = url
            } else if let string = item as? String {
                droppedURL = URL(string: string)
            } else {
                droppedURL = nil
            }

            guard let droppedURL else { return }

            Task { @MainActor in
                state.loadVideo(droppedURL)
            }
        }

        return true
    }
}
