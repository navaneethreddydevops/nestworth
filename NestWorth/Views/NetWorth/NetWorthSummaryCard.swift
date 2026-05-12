import SwiftUI

struct NetWorthSummaryCard: View {
    let totalAssets: Double
    let totalLiabilities: Double
    let previousNetWorth: Double?

    private var netWorth: Double { totalAssets - totalLiabilities }
    private var netWorthColor: Color { netWorth >= 0 ? AppTheme.income : AppTheme.expense }
    private var delta: Double? {
        guard let prev = previousNetWorth else { return nil }
        return netWorth - prev
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient header
            VStack(spacing: 8) {
                Text("Net Worth")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))

                AnimatedCurrencyText(
                    amount: netWorth,
                    font: .system(size: 40, weight: .bold),
                    color: .white
                )

                if let delta {
                    deltaLabel(delta)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
            .background(netWorth >= 0 ? AppTheme.netWorthGradient : LinearGradient(
                colors: [AppTheme.expense.opacity(0.9), AppTheme.expense],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))

            // Asset / Liability strip
            HStack(spacing: 0) {
                statStrip(label: "Assets", amount: totalAssets, color: AppTheme.income)
                Rectangle()
                    .fill(Color(uiColor: .separator).opacity(0.3))
                    .frame(width: 1, height: 40)
                statStrip(label: "Liabilities", amount: totalLiabilities, color: AppTheme.expense)
            }
            .padding(.vertical, 14)
            .background(AppTheme.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
    }

    @ViewBuilder
    private func statStrip(label: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            AnimatedCurrencyText(amount: amount, font: .subheadline.weight(.semibold), color: color, compact: true)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func deltaLabel(_ delta: Double) -> some View {
        let isPositive = delta >= 0
        let color: Color = delta == 0 ? .white.opacity(0.6) : (isPositive ? Color(red: 0.6, green: 1, blue: 0.75) : Color(red: 1, green: 0.6, blue: 0.6))
        let icon = delta == 0 ? "minus" : (isPositive ? "arrow.up.right" : "arrow.down.right")

        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
            Text(CurrencyFormatter.formatCompact(abs(delta)))
                .font(.caption.weight(.semibold))
                .fontDesign(.monospaced)
            Text("from last snapshot")
                .font(.caption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.white.opacity(0.15), in: Capsule())
    }
}
