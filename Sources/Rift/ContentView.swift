import SwiftUI
import UniformTypeIdentifiers
import AppKit

// MARK: - App icon from SVG

private struct RiftLogo: View {
    var body: some View {
        if let bundleURL = Bundle.main.url(forResource: "Rift_Rift", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL),
           let url = bundle.url(forResource: "rift-logo", withExtension: "svg"),
           let image = NSImage(contentsOf: url) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
        }
    }
}

// MARK: - Ambient particle for cinematic atmosphere

private struct AmbientParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var delay: Double
}

struct ContentView: View {
    @StateObject private var state = PlayerState()
    @State private var isDropTargeted = false

    @State private var areControlsVisible = true
    @State private var isHoveringControls = false
    @State private var hideControlsTask: Task<Void, Never>? = nil
    @State private var mouseEventMonitor: Any? = nil

    @State private var particles: [AmbientParticle] = []
    @State private var promptPulse: CGFloat = 0

    @State private var controlsPosition: CGPoint = .zero
    @State private var controlsDrag: CGSize = .zero
    @State private var controlsSize: CGSize = .zero
    @State private var isPositionInitialized = false
    @State private var isDraggingControls = false

    var body: some View {
        ZStack {
            appBackdrop

            if !state.hasVideo {
                ambientParticles
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if state.hasVideo {
                Group {
                    if state.playbackBackend == .directFFmpeg, let directPlaybackURL = state.directPlaybackURL {
                        DirectFFmpegPlayerView(url: directPlaybackURL, state: state)
                    } else if usesMetalRenderer {
                        RiftPlayerView(
                            player: state.player,
                            fpsMode: state.fpsMode,
                            interpolationMode: state.interpolationMode,
                            sourceFrameRate: state.sourceFrameRate,
                            visualEnhancementsEnabled: state.visualEnhancementsEnabled
                        ) { stats in
                            state.currentRenderingFPS = stats.renderingFPS
                            state.isArtificialInterpolationActive = stats.isArtificialInterpolationActive
                            state.fluxWorkingWidth = stats.fluxWorkingWidth
                            state.fluxOpticalFlowUsage = stats.opticalFlowUsage
                            state.fluxBlendFallbackUsage = stats.blendFallbackUsage
                            state.rifeStatus = stats.rifeStatus
                            state.isRIFELoaded = stats.isRIFELoaded
                            state.rifeEnabled = stats.isRIFELoaded && state.interpolationMode != .disabled && state.interpolationMode != .motion2Intense
                            if !stats.isRIFELoaded && state.interpolationMode != .disabled && state.interpolationMode != .motion2Intense {
                                state.interpolationMode = .disabled
                                state.fpsMode = .native
                            }
                        }
                    } else {
                        NativeVideoPlayerView(player: state.player)
                    }
                }
                .ignoresSafeArea()
                .overlay(videoVignette)
                .transition(.opacity.combined(with: .scale(scale: 1.01)))
            }

            if state.hasVideo, let subtitleText = state.currentSubtitleText, !subtitleText.isEmpty {
                subtitleOverlay(subtitleText)
                    .transition(.opacity)
            }

            if !state.hasVideo {
                openVideoPrompt
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }

            if !state.hasVideo {
                filmGrainOverlay
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            GeometryReader { geometry in
                ZStack {
                    controlsContrastField

                    PlayerControlsView(state: state)
                }
                .opacity(areControlsVisible ? 1.0 : 0.0)
                .scaleEffect(areControlsVisible ? 1 : 0.96)
                .background {
                    GeometryReader { proxy in
                        Color.clear.onAppear { controlsSize = proxy.size }
                    }
                }
                .position(
                    x: controlsPosition.x + controlsDrag.width,
                    y: controlsPosition.y + controlsDrag.height
                )
                .scaleEffect(isDraggingControls ? 0.98 : 1)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isDraggingControls)
                .onAppear {
                    guard !isPositionInitialized else { return }
                    controlsPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height - 82)
                    isPositionInitialized = true
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            controlsDrag = value.translation
                            isDraggingControls = true
                        }
                        .onEnded { value in
                            let margin: CGFloat = 8
                            let halfW = controlsSize.width / 2
                            let halfH = controlsSize.height / 2
                            let w = geometry.size.width
                            let h = geometry.size.height
                            var newX = controlsPosition.x + value.translation.width
                            var newY = controlsPosition.y + value.translation.height
                            newX = max(halfW + margin, min(w - halfW - margin, newX))
                            newY = max(halfH + margin, min(h - halfH - margin, newY))
                            controlsPosition = CGPoint(x: newX, y: newY)
                            controlsDrag = .zero
                            isDraggingControls = false
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 2)
                        .onEnded {
                            let w = geometry.size.width
                            let h = geometry.size.height
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                controlsPosition = CGPoint(x: w / 2, y: h - 82)
                                controlsDrag = .zero
                            }
                        }
                )
                .onHover { hovering in
                    isHoveringControls = hovering
                    resetHideTimer()
                }
            }
        }
        .background(appBackdrop)
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDropTargeted, perform: handleDrop)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: state.hasVideo)
        .animation(.spring(response: 0.28, dampingFraction: 0.75), value: isDropTargeted)
        .onAppear {
            setupMouseMonitor()
            handleOpenURLs(AppDelegate.takePendingOpenURLs())
            generateParticles()
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                promptPulse = 1.0
            }
        }
        .onDisappear {
            cleanupMouseMonitor()
            state.cleanup()
        }
        .onChange(of: state.isPlaying) {
            resetHideTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .riftOpenURLs)) { notification in
            let urls = notification.userInfo?["urls"] as? [URL] ?? []
            handleOpenURLs(urls)
        }
    }

    private var usesMetalRenderer: Bool {
        !state.usesNativeVideoLayer
    }

    private func setupMouseMonitor() {
        mouseEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown]) { event in
            resetHideTimer()
            return event
        }
    }

    private func cleanupMouseMonitor() {
        if let monitor = mouseEventMonitor {
            NSEvent.removeMonitor(monitor)
            mouseEventMonitor = nil
        }
        hideControlsTask?.cancel()
        hideControlsTask = nil
        NSCursor.unhide()
    }

    private func resetHideTimer() {
        if !areControlsVisible {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                areControlsVisible = true
            }
            NSCursor.unhide()
        }

        hideControlsTask?.cancel()

        guard state.hasVideo && state.isPlaying else { return }
        guard !isHoveringControls else { return }

        hideControlsTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.36, dampingFraction: 0.85)) {
                areControlsVisible = false
            }
            NSCursor.hide()
        }
    }

    private func generateParticles() {
        var newParticles: [AmbientParticle] = []
        for _ in 0..<96 {
            newParticles.append(AmbientParticle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1.5...5.0),
                speed: CGFloat.random(in: 0.08...0.35),
                opacity: Double.random(in: 0.12...0.55),
                delay: Double.random(in: 0...20)
            ))
        }
        particles = newParticles
    }

    private var ambientParticles: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for p in particles {
                    let drift = sin(time * 0.25 + p.delay * 1.7) * 28
                    let rise = fmod(time * p.speed + p.delay * 25, size.height * 1.4)
                    let xPos = (p.x * size.width * 0.9 + size.width * 0.05) + drift
                    let yPos = size.height - rise + size.height * 0.2
                    let breathe = 0.5 + 0.5 * sin(time * 0.4 + p.delay * 2.3)
                    let particleOpacity = p.opacity * breathe

                    var dotContext = context
                    dotContext.opacity = particleOpacity
                    dotContext.fill(
                        Path(ellipseIn: CGRect(x: xPos, y: yPos, width: p.size, height: p.size)),
                        with: .color(Color(red: 0.55, green: 0.78, blue: 1.0))
                    )
                }
            }
        }
        .drawingGroup()
    }

    private var appBackdrop: some View {
        ZStack {
            NativeVisualEffectView(
                material: .hudWindow,
                blendingMode: .behindWindow
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.010, green: 0.035, blue: 0.095).opacity(0.88),
                    Color(red: 0.018, green: 0.075, blue: 0.190).opacity(0.82),
                    Color(red: 0.008, green: 0.025, blue: 0.065).opacity(0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color(red: 0.22, green: 0.42, blue: 0.88).opacity(0.20),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 60,
                endRadius: 680
            )

            RadialGradient(
                colors: [
                    Color(red: 0.03, green: 0.14, blue: 0.42).opacity(0.30),
                    .clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 720
            )

            RadialGradient(
                colors: [
                    Color(red: 0.55, green: 0.78, blue: 1.0).opacity(0.03),
                    .clear
                ],
                center: .bottom,
                startRadius: 40,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }

    private var filmGrainOverlay: some View {
        TimelineView(.animation(paused: false)) { timeline in
            let seed = Int(timeline.date.timeIntervalSinceReferenceDate * 24)
            Canvas { context, size in
                for row in 0..<Int(size.height / 4) {
                    for col in 0..<Int(size.width / 3) {
                        let hash = seed ^ (row * 137) ^ (col * 251)
                        let gray = Double((hash & 0xFF)) / 512.0
                        let rect = CGRect(
                            x: CGFloat(col) * 3 + CGFloat.random(in: -0.5...0.5),
                            y: CGFloat(row) * 4 + CGFloat.random(in: -0.5...0.5),
                            width: 2.5,
                            height: 3.5
                        )
                        context.fill(
                            Path(rect),
                            with: .color(.white.opacity(gray * 0.06))
                        )
                    }
                }
            }
            .blendMode(.overlay)
        }
    }

    private var openVideoPrompt: some View {
        Button {
            state.openVideo()
        } label: {
            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.50, blue: 1.0).opacity(0.20 + promptPulse * 0.15),
                                    Color(red: 0.10, green: 0.22, blue: 0.70).opacity(0.06 + promptPulse * 0.06),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10 + promptPulse * 20,
                                endRadius: 110 + promptPulse * 30
                            )
                        )
                        .frame(width: 220 + promptPulse * 30, height: 220 + promptPulse * 30)
                        .blur(radius: 6)
                        .scaleEffect(isDropTargeted ? 1.35 : 1)

                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.50, green: 0.75, blue: 1.0).opacity(0.30 + promptPulse * 0.20),
                                    Color(red: 0.20, green: 0.44, blue: 0.90).opacity(0.06 + promptPulse * 0.06),
                                    Color(red: 0.50, green: 0.75, blue: 1.0).opacity(0.15 + promptPulse * 0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2 + promptPulse * 1.0
                        )
                        .frame(width: 180 + promptPulse * 16, height: 180 + promptPulse * 16)

                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.40, green: 0.65, blue: 1.0).opacity(0.08 + promptPulse * 0.10),
                                    .clear,
                                    Color(red: 0.40, green: 0.65, blue: 1.0).opacity(0.04 + promptPulse * 0.06)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5 + promptPulse * 0.6
                        )
                        .frame(width: 240 + promptPulse * 20, height: 240 + promptPulse * 20)

                    RiftLogo()

                    RoundedRectangle(cornerRadius: 60, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.50, green: 0.75, blue: 1.0).opacity(isDropTargeted ? 0.30 : 0.06),
                                    Color(red: 0.20, green: 0.44, blue: 0.90).opacity(isDropTargeted ? 0.15 : 0.02),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isDropTargeted ? 2 : 1
                        )
                        .frame(width: 112, height: 76)
                        .offset(y: 78)
                        .opacity(isDropTargeted ? 1 : 0.5)
                }
                .frame(width: 280, height: 280)
                .shadow(color: Color(red: 0.20, green: 0.45, blue: 0.95).opacity(0.15), radius: 50, x: 0, y: 20)

                VStack(spacing: 10) {
                    Text("Abrir video")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))

                    Text("Arrastra un archivo hasta aqui\no haz clic para explorar")
                        .font(.system(size: 15, weight: .regular))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundStyle(.white.opacity(0.48))

                    if let statusMessage = state.statusMessage {
                        Text(statusMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(red: 0.45, green: 0.70, blue: 1.0))
                            .padding(.top, 4)
                    }
                }
            }
            .scaleEffect(isDropTargeted ? 1.03 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.bottom, 80)
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
                Color(red: 0.06, green: 0.10, blue: 0.22).opacity(0.20),
                .black.opacity(0.08)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(maxWidth: 880, maxHeight: 120)
        .blur(radius: 18)
        .allowsHitTesting(false)
    }

    private func subtitleOverlay(_ text: String) -> some View {
        VStack {
            Spacer()

            Text(text)
                .font(.system(size: 28, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.95), radius: 4, x: 0, y: 1)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(.black.opacity(0.48))
                }
                .frame(maxWidth: 920)
                .padding(.horizontal, 34)
                .padding(.bottom, areControlsVisible ? 154 : 58)
        }
        .allowsHitTesting(false)
        .animation(.spring(response: 0.3, dampingFraction: 0.82), value: areControlsVisible)
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

    private func handleOpenURLs(_ urls: [URL]) {
        guard let url = urls.first else { return }
        state.loadVideo(url)
        AppDelegate.bringPlayerWindowToFront()
    }
}
