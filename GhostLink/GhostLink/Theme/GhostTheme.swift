import SwiftUI

enum GhostTheme {
    static let background = Color(hex: 0x0A0A0A)
    static let pureBlack = Color(hex: 0x000000)
    static let neonPink = Color(hex: 0xFF2A6D)
    static let neonPinkLight = Color(hex: 0xFF66C4)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)

    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.82, blendDuration: 0)
    static let springFast = Animation.spring(response: 0.25, dampingFraction: 0.78, blendDuration: 0)

    static let asymmetricTransition: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )

    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    static func formatDateTime(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct NeonBorderModifier: ViewModifier {
    var isHighlighted: Bool = false

    func body(content: Content) -> some View {
        content
            .background(GhostTheme.background)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [GhostTheme.neonPink, GhostTheme.neonPinkLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isHighlighted ? 2.5 : 1.5
                    )
            )
            .shadow(color: isHighlighted ? GhostTheme.neonPink.opacity(0.45) : .clear, radius: 12)
    }
}

extension View {
    func neonBorder(highlighted: Bool = false) -> some View {
        modifier(NeonBorderModifier(isHighlighted: highlighted))
    }
}
