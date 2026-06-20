import SwiftUI

struct LiquidGlassButton: View {
    enum Size {
        case compact
        case largeIcon
        case metric
    }

    var title: String?
    var subtitle: String?
    var systemName: String?
    var isActive = false
    var size: Size = .compact
    var action: () -> Void

    @State private var isPressed = false
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            label
            .foregroundStyle(isActive ? .white : isHovered ? .white.opacity(0.92) : .white.opacity(0.76))
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        isActive
                            ? AnyShapeStyle(LinearGradient(
                                colors: [
                                    Color(red: 0.16, green: 0.50, blue: 0.96).opacity(0.30),
                                    Color(red: 0.10, green: 0.34, blue: 0.86).opacity(0.20),
                                    Color(red: 0.55, green: 0.78, blue: 1.0).opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            : AnyShapeStyle(
                                isHovered
                                    ? .white.opacity(0.06)
                                    : .white.opacity(size == .metric ? 0.05 : 0.0)
                            )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isActive
                            ? AnyShapeStyle(LinearGradient(
                                colors: [
                                    Color(red: 0.36, green: 0.66, blue: 1.0).opacity(0.44),
                                    Color(red: 0.16, green: 0.48, blue: 0.95).opacity(0.22)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            : AnyShapeStyle(
                                isHovered
                                    ? .white.opacity(0.18)
                                    : .white.opacity(size == .metric ? 0.18 : 0.0)
                            ),
                        lineWidth: isActive ? 1.2 : (isHovered ? 0.8 : (size == .metric ? 1 : 0))
                    )
            }
            .shadow(
                color: isActive ? Color(red: 0.30, green: 0.55, blue: 1.0).opacity(0.20) : .black.opacity(0.08),
                radius: isActive ? 12 : 6,
                x: 0,
                y: isActive ? 6 : 4
            )
            .scaleEffect(isPressed ? 0.92 : (isHovered ? 1.04 : 1))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.18)) {
                isHovered = hovering
            }
        }
    }

    @ViewBuilder
    private var label: some View {
        switch size {
        case .largeIcon:
            Image(systemName: systemName ?? "")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 26, height: 26)

        case .metric:
            HStack(spacing: 8) {
                if let systemName {
                    Image(systemName: systemName)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 15)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title ?? "")
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 8, weight: .regular))
                            .foregroundStyle(.white.opacity(0.78))
                            .lineLimit(1)
                    }
                }
            }
            .frame(width: 80, height: 37)

        case .compact:
            if let systemName {
                Image(systemName: systemName)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 34, height: 34)
            } else if let title {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(height: 34)
                    .padding(.horizontal, 10)
            }
        }
    }

    private var cornerRadius: CGFloat {
        size == .metric ? 9 : 13
    }
}
