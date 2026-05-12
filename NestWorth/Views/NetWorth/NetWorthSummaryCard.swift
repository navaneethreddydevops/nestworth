import SwiftUI

struct NetWorthSummaryCard: View {
    let totalAssets: Double
    let totalLiabilities: Double

    private var netWorth: Double { totalAssets - totalLiabilities }
    private var netWorthColor: Color { netWorth >= 0 ? .green : .red }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("Net Worth")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(CurrencyFormatter.format(netWorth))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(netWorthColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()

            HStack {
                statItem(label: "Assets", amount: totalAssets, color: .green)
                Divider().frame(height: 36)
                statItem(label: "Liabilities", amount: totalLiabilities, color: .red)
            }
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }

    @ViewBuilder
    private func statItem(label: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.formatCompact(amount))
                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}
