import AppKit
import SwiftUI

struct LiquidGlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = 28
    var material: NSVisualEffectView.Material = .hudWindow
    @ViewBuilder var content: Content

    var body: some View {
        // Native blur with restrained optical layers keeps the panel glassy without adding new chrome.
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.clear)
                    .background {
                        NativeVisualEffectView(material: material)
                            .opacity(0.68)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.17),
                                        Color(red: 0.44, green: 0.44, blue: 1.0).opacity(0.045),
                                        .white.opacity(0.012)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.black.opacity(0.018))
                            .blendMode(.multiply)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.46),
                                .white.opacity(0.12),
                                Color(red: 0.50, green: 0.46, blue: 1.0).opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius - 1, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 0.7)
                    .padding(1)
            }
            .overlay(alignment: .top) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.38), .white.opacity(0.04), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 22)
                    .padding(.top, 1)
                    .blur(radius: 0.35)
            }
            .shadow(color: .black.opacity(0.18), radius: 22, x: 0, y: 14)
            .shadow(color: Color(red: 0.42, green: 0.38, blue: 1.0).opacity(0.10), radius: 24, x: 0, y: 0)
            .compositingGroup()
    }
}
