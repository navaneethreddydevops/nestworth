import SwiftUI

struct BudgetSummaryCard: View {
    let income: Double
    let expenses: Double

    private var savings: Double { income - expenses }
    private var savingsColor: Color { savings >= 0 ? AppTheme.income : AppTheme.expense }
    private var savingsPct: Double { income > 0 ? min(savings / income, 1) : 0 }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                statTile(label: "Income", amount: income, color: AppTheme.income)
                divider()
                statTile(label: "Expenses", amount: expenses, color: AppTheme.expense)
                divider()
                statTile(label: "Saved", amount: savings, color: savingsColor)
            }

            if income > 0 {
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(uiColor: .systemFill))
                                .frame(height: 6)
                            Capsule()
                                .fill(savingsColor)
                                .frame(width: max(0, geo.size.width * savingsPct), height: 6)
                                .animation(.spring(duration: 0.5), value: savingsPct)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Text("Savings rate")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(savingsPct * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(savingsColor)
                    }
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .glassBackground()
    }

    @ViewBuilder
    private func statTile(label: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            AnimatedCurrencyText(amount: amount, font: .subheadline.weight(.bold), color: color, compact: true)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func divider() -> some View {
        Rectangle()
            .fill(Color(uiColor: .separator).opacity(0.5))
            .frame(width: 1, height: 36)
    }
}
