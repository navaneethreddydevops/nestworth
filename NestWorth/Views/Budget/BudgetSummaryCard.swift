import SwiftUI

struct BudgetSummaryCard: View {
    let income: Double
    let expenses: Double

    private var savings: Double { income - expenses }
    private var savingsColor: Color { savings >= 0 ? AppTheme.income : AppTheme.expense }
    private var savingsPct: Double { income > 0 ? max(0, min(savings / income, 1)) : 0 }
    private var spendPct: Double { income > 0 ? min(expenses / income, 1) : 0 }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient header strip
            HStack(spacing: 0) {
                gradientStatTile(
                    label: "Income",
                    amount: income,
                    gradient: AppTheme.incomeGradient,
                    icon: "arrow.down.circle.fill"
                )
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 1, height: 48)
                gradientStatTile(
                    label: "Expenses",
                    amount: expenses,
                    gradient: AppTheme.expenseGradient,
                    icon: "arrow.up.circle.fill"
                )
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 1, height: 48)
                gradientStatTile(
                    label: "Saved",
                    amount: savings,
                    gradient: savings >= 0 ? AppTheme.incomeGradient : AppTheme.expenseGradient,
                    icon: savings >= 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
                )
            }
            .padding(.vertical, 16)
            .background(AppTheme.netWorthGradient)

            // Progress section
            VStack(spacing: 10) {
                if income > 0 {
                    // Segmented spend bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5).fill(Color(uiColor: .systemFill)).frame(height: 10)
                            HStack(spacing: 2) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(AppTheme.expenseGradient)
                                    .frame(width: max(0, geo.size.width * CGFloat(spendPct)), height: 10)
                                    .animation(.spring(duration: 0.6), value: spendPct)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .frame(height: 10)

                    HStack {
                        HStack(spacing: 4) {
                            Circle().fill(AppTheme.expense).frame(width: 7, height: 7)
                            Text("Spent \(Int(spendPct * 100))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Circle().fill(AppTheme.income).frame(width: 7, height: 7)
                            Text("Saved \(Int(savingsPct * 100))%")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(savingsColor)
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.vertical, 12)
            .background(AppTheme.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
    }

    @ViewBuilder
    private func gradientStatTile(label: String, amount: Double, gradient: LinearGradient, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
            AnimatedCurrencyText(amount: amount, font: .system(size: 15, weight: .bold, design: .rounded), color: .white, compact: true)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.75))
                .textCase(.uppercase)
                .tracking(0.3)
        }
        .frame(maxWidth: .infinity)
    }
}
