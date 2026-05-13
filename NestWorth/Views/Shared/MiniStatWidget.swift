import SwiftUI

struct MiniStatWidget: View {
    let icon: String
    let label: String
    let value: String
    var sub: String? = nil
    var accentColor: Color = AppTheme.mint
    var gradient: LinearGradient = AppTheme.mintVioletGradient  // kept for API compat
    var valueColor: Color = AppTheme.textPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(10 * 0.08)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accentColor)
            }
            .padding(.bottom, 14)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let sub {
                Text(sub)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.textTertiary)
                    .padding(.top, 4)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .darkCard(cornerRadius: AppTheme.widgetCornerRadius)
    }
}
