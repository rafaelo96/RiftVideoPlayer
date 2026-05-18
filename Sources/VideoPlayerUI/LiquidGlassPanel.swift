import SwiftUI

struct LiquidGlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = 28
    @ViewBuilder var content: Content

    var body: some View {
        // Layered material, tint, border, and shadow create the Liquid Glass treatment.
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.12),
                                        Color(red: 0.38, green: 0.44, blue: 1.0).opacity(0.08),
                                        .white.opacity(0.03)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.black.opacity(0.04))
                            .blendMode(.multiply)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.34),
                                .white.opacity(0.10),
                                Color(red: 0.52, green: 0.46, blue: 1.0).opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: 18)
            .shadow(color: Color(red: 0.42, green: 0.38, blue: 1.0).opacity(0.12), radius: 24, x: 0, y: 0)
    }
}
