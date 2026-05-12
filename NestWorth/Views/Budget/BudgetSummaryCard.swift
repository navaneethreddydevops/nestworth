import SwiftUI

struct BudgetSummaryCard: View {
    let income: Double
    let expenses: Double

    private var savings: Double { income - expenses }

    var body: some View {
        HStack(spacing: 1) {
            tile(title: "Income", amount: income, color: .green)
            Divider().frame(height: 44)
            tile(title: "Expenses", amount: expenses, color: .red)
            Divider().frame(height: 44)
            tile(title: "Saved", amount: savings, color: savings >= 0 ? .green : .red)
        }
        .padding(.vertical, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    @ViewBuilder
    private func tile(title: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
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
