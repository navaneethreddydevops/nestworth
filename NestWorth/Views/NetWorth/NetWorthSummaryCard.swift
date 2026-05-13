import SwiftUI

struct NetWorthSummaryCard: View {
    let totalAssets: Double
    let totalLiabilities: Double
    let previousNetWorth: Double?

    private var netWorth: Double { totalAssets - totalLiabilities }
    private var equityRatio: Double { totalAssets > 0 ? max(0, min(netWorth / totalAssets, 1)) : 0 }
    private var delta: Double? {
        guard let prev = previousNetWorth else { return nil }
        return netWorth - prev
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Net Worth")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))

                    AnimatedCurrencyText(
                        amount: netWorth,
                        font: .system(size: 38, weight: .bold, design: .rounded),
                        color: .white
                    )

                    if let delta {
                        deltaLabel(delta)
                    }
                }
                Spacer()
                CircularProgressRing(
                    progress: equityRatio,
                    gradient: LinearGradient(
                        colors: [.white.opacity(0.9), .white.opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 7,
                    size: 66,
                    label: "\(Int(equityRatio * 100))%",
                    sublabel: "equity"
                )
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.top, 20)
            .padding(.bottom, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(netWorth >= 0 ? AppTheme.netWorthGradient : AppTheme.expenseGradient)

            // Stacked asset/liability bar
            GeometryReader { geo in
                let assetW = totalAssets + totalLiabilities > 0
                    ? geo.size.width * CGFloat(totalAssets / (totalAssets + totalLiabilities))
                    : geo.size.width * 0.5
                HStack(spacing: 0) {
                    Rectangle().fill(AppTheme.income).frame(width: assetW, height: 4)
                    Rectangle().fill(AppTheme.expense).frame(maxWidth: .infinity, maxHeight: 4)
                }
            }
            .frame(height: 4)
            .background(AppTheme.surface)

            // Stat strip
            HStack(spacing: 0) {
                statStrip(label: "Assets", amount: totalAssets, color: AppTheme.income, icon: "building.columns.fill")
                Rectangle()
                    .fill(Color(uiColor: .separator).opacity(0.3))
                    .frame(width: 1, height: 44)
                statStrip(label: "Liabilities", amount: totalLiabilities, color: AppTheme.expense, icon: "creditcard.fill")
            }
            .padding(.vertical, 14)
            .background(AppTheme.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
    }

    @ViewBuilder
    private func statStrip(label: String, amount: Double, color: Color, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(color.opacity(0.7))
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                AnimatedCurrencyText(amount: amount, font: .subheadline.weight(.semibold), color: color, compact: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func deltaLabel(_ delta: Double) -> some View {
        let isPositive = delta >= 0
        let color: Color = delta == 0 ? .white.opacity(0.6) : (isPositive ? Color(red: 0.6, green: 1, blue: 0.75) : Color(red: 1, green: 0.6, blue: 0.6))
        let icon = delta == 0 ? "minus" : (isPositive ? "arrow.up.right" : "arrow.down.right")
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2.weight(.bold))
            Text(CurrencyFormatter.formatCompact(abs(delta))).font(.caption.weight(.semibold)).fontDesign(.monospaced)
            Text("from last snapshot").font(.caption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.white.opacity(0.15), in: Capsule())
    }
}
