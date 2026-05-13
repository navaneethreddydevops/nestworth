import SwiftUI

struct GlassCard<Content: View>: View {
    let title: String?
    let content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(12 * 0.08)
                    .textCase(.uppercase)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            content
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .darkCard()
    }
}
