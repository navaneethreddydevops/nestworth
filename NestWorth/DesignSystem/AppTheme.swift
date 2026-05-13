import SwiftUI

enum AppTheme {

    // MARK: - Semantic Colors
    static let income  = Color(red: 0.094, green: 0.753, blue: 0.475)
    static let expense = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let accent  = Color(red: 0.106, green: 0.310, blue: 0.847)
    static let neutral = Color(uiColor: .secondaryLabel)
    static let warning = Color(red: 0.984, green: 0.749, blue: 0.141)
    static let purple  = Color(red: 0.545, green: 0.361, blue: 0.965)
    static let teal    = Color(red: 0.024, green: 0.714, blue: 0.831)

    // MARK: - Surfaces
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface    = Color(uiColor: .secondarySystemGroupedBackground)
    static let surfaceTertiary = Color(uiColor: .tertiarySystemGroupedBackground)

    // MARK: - Asset Type Colors
    static let assetColors: [Color] = [
        Color(red: 0.106, green: 0.310, blue: 0.847),
        Color(red: 0.094, green: 0.753, blue: 0.475),
        Color(red: 0.545, green: 0.361, blue: 0.965),
        Color(red: 0.984, green: 0.549, blue: 0.086),
        Color(red: 0.024, green: 0.714, blue: 0.831),
        Color(red: 0.925, green: 0.251, blue: 0.600),
        Color(uiColor: .secondaryLabel),
    ]

    // MARK: - Gradients
    static let netWorthGradient = LinearGradient(
        colors: [
            Color(red: 0.106, green: 0.310, blue: 0.847),
            Color(red: 0.298, green: 0.137, blue: 0.855)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let dashboardGradient = LinearGradient(
        colors: [
            Color(red: 0.055, green: 0.180, blue: 0.620),
            Color(red: 0.200, green: 0.080, blue: 0.700)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let incomeGradient = LinearGradient(
        colors: [Color(red: 0.094, green: 0.753, blue: 0.475),
                 Color(red: 0.031, green: 0.588, blue: 0.353)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let expenseGradient = LinearGradient(
        colors: [Color(red: 0.937, green: 0.267, blue: 0.267),
                 Color(red: 0.780, green: 0.120, blue: 0.120)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [Color(red: 0.106, green: 0.310, blue: 0.847),
                 Color(red: 0.298, green: 0.137, blue: 0.855)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let purpleGradient = LinearGradient(
        colors: [Color(red: 0.545, green: 0.361, blue: 0.965),
                 Color(red: 0.380, green: 0.200, blue: 0.820)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let warningGradient = LinearGradient(
        colors: [Color(red: 0.984, green: 0.749, blue: 0.141),
                 Color(red: 0.960, green: 0.580, blue: 0.020)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static func chartGradient(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.35), color.opacity(0.0)],
            startPoint: .top, endPoint: .bottom
        )
    }

    // MARK: - Layout
    static let cardCornerRadius: CGFloat = 18
    static let widgetCornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 16
    static let rowSpacing: CGFloat = 12
}

// MARK: - View modifiers
extension View {
    func glassBackground(cornerRadius: CGFloat = AppTheme.cardCornerRadius) -> some View {
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
    }

    func surfaceBackground(cornerRadius: CGFloat = AppTheme.cardCornerRadius) -> some View {
        self.background(AppTheme.surface, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    func gradientCard(_ gradient: LinearGradient, cornerRadius: CGFloat = AppTheme.widgetCornerRadius) -> some View {
        self.background(gradient, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.20), radius: 16, y: 7)
    }
}
