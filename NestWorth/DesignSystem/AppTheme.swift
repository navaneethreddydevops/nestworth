import SwiftUI

enum AppTheme {

    // MARK: - Backgrounds
    static let background      = Color(hex: "#0A0B0F")
    static let surface         = Color(hex: "#14171F")
    static let surface2        = Color(hex: "#1A1E27")
    static let surface3        = Color(hex: "#232732")
    static let hairline        = Color.white.opacity(0.07)
    static let hairline2       = Color.white.opacity(0.12)

    // MARK: - Text
    static let textPrimary     = Color.white
    static let textSecondary   = Color.white.opacity(0.82)
    static let textTertiary    = Color.white.opacity(0.58)
    static let textQuaternary  = Color.white.opacity(0.36)

    // MARK: - Accents
    static let mint            = Color(hex: "#5EEAD4")
    static let violet          = Color(hex: "#C4B5FD")
    static let cyan            = Color(hex: "#67E8F9")
    static let coral           = Color(hex: "#FCA5A5")
    static let amber           = Color(hex: "#FCD34D")

    // MARK: - Semantic aliases
    static let income          = mint
    static let expense         = coral
    static let accent          = mint
    static let neutral         = textTertiary
    static let warning         = amber
    static let purple          = violet
    static let teal            = cyan
    static let surfaceTertiary = surface3

    // MARK: - Category / asset palette (7 slots)
    static let categoryColors: [Color] = [
        Color(hex: "#60A5FA"),
        Color(hex: "#34D399"),
        Color(hex: "#FBBF24"),
        Color(hex: "#A78BFA"),
        Color(hex: "#F472B6"),
        Color(hex: "#2DD4BF"),
        Color(hex: "#94A3B8"),
    ]
    static let assetColors: [Color] = categoryColors

    // MARK: - Gradients
    static let mintVioletGradient = LinearGradient(
        colors: [Color(hex: "#5EEAD4"), Color(hex: "#C4B5FD")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Legacy aliases
    static let netWorthGradient  = mintVioletGradient
    static let dashboardGradient = mintVioletGradient
    static let accentGradient    = mintVioletGradient
    static let incomeGradient    = LinearGradient(
        colors: [Color(hex: "#5EEAD4"), Color(hex: "#2DD4BF")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let expenseGradient   = LinearGradient(
        colors: [Color(hex: "#FCA5A5"), Color(hex: "#F87171")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let purpleGradient    = LinearGradient(
        colors: [Color(hex: "#C4B5FD"), Color(hex: "#A78BFA")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let warningGradient   = LinearGradient(
        colors: [Color(hex: "#FCD34D"), Color(hex: "#FBBF24")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static func chartGradient(_ color: Color) -> LinearGradient { chartFillGradient(color) }
    static func chartFillGradient(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.25), color.opacity(0.0)],
            startPoint: .top, endPoint: .bottom
        )
    }

    // MARK: - Layout
    static let cardCornerRadius: CGFloat   = 16
    static let widgetCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat        = 16
    static let sectionSpacing: CGFloat     = 16
    static let rowSpacing: CGFloat         = 12
}

// MARK: - View modifiers
extension View {
    func darkCard(cornerRadius: CGFloat = AppTheme.cardCornerRadius) -> some View {
        self
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(AppTheme.hairline, lineWidth: 0.5))
    }

    func glassBackground(cornerRadius: CGFloat = AppTheme.cardCornerRadius) -> some View {
        darkCard(cornerRadius: cornerRadius)
    }

    func surfaceBackground(cornerRadius: CGFloat = AppTheme.cardCornerRadius) -> some View {
        darkCard(cornerRadius: cornerRadius)
    }

    func gradientCard(_ gradient: LinearGradient, cornerRadius: CGFloat = AppTheme.widgetCornerRadius) -> some View {
        darkCard(cornerRadius: cornerRadius)
    }
}

// MARK: - Color hex init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double((int      ) & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
