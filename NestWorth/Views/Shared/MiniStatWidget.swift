import SwiftUI

/// A compact 2-column grid widget tile with gradient icon and label+value.
struct MiniStatWidget: View {
    let icon: String
    let label: String
    let value: String
    let gradient: LinearGradient
    var valueColor: Color = .primary
    var trend: TrendDirection? = nil

    enum TrendDirection { case up, down, flat }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(gradient)
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                if let trend {
                    trendBadge(trend)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceBackground(cornerRadius: AppTheme.widgetCornerRadius)
    }

    @ViewBuilder
    private func trendBadge(_ direction: TrendDirection) -> some View {
        let (icon, color): (String, Color) = switch direction {
        case .up:   ("arrow.up.right", AppTheme.income)
        case .down: ("arrow.down.right", AppTheme.expense)
        case .flat: ("minus", AppTheme.neutral)
        }
        Image(systemName: icon)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(5)
            .background(color.opacity(0.12), in: Circle())
    }
}
