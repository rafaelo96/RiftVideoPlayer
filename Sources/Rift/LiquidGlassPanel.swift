import AppKit
import SwiftUI

// MARK: - Glass Background

struct GlassBackground: View {
    var cornerRadius: CGFloat = 16
    var blendsWithWindow: Bool = false

    var body: some View {
        ZStack {
            NativeVisualEffectView(
                material: .hudWindow,
                blendingMode: blendsWithWindow ? .withinWindow : .behindWindow
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.45, green: 0.70, blue: 1.0).opacity(0.02),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.12),
                            .white.opacity(0.04),
                            Color(red: 0.30, green: 0.55, blue: 1.0).opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }
}

// MARK: - Glass Capsule

struct GlassCapsule: View {
    var body: some View {
        ZStack {
            NativeVisualEffectView(
                material: .hudWindow,
                blendingMode: .withinWindow
            )
            .clipShape(Capsule())

            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.10),
                            .white.opacity(0.03),
                            Color(red: 0.30, green: 0.55, blue: 1.0).opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }
}

// MARK: - Liquid Glass Panel

struct LiquidGlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var blendsWithWindow: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(GlassBackground(cornerRadius: cornerRadius, blendsWithWindow: blendsWithWindow))
            .shadow(color: .black.opacity(0.20), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Glass Button Modifier

struct GlassButtonStyle: ViewModifier {
    @State private var isHovered = false
    var cornerRadius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isHovered
                        ? Color(red: 0.40, green: 0.65, blue: 1.0).opacity(0.08)
                        : .clear)
                    .animation(.easeOut(duration: 0.12), value: isHovered)
            }
            .onHover { isHovered = $0 }
    }
}

extension View {
    func glassButton(cornerRadius: CGFloat = 8) -> some View {
        modifier(GlassButtonStyle(cornerRadius: cornerRadius))
    }
}
