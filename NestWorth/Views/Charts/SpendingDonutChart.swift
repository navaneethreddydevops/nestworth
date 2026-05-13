import SwiftUI
import Charts

struct SpendingDonutChart: View {
    let expenses: [ExpenseEntry]

    private struct Slice: Identifiable {
        let id = UUID()
        let category: ExpenseCategory
        let amount: Double
    }

    private var slices: [Slice] {
        let grouped = Dictionary(grouping: expenses, by: \.category)
        let sorted = grouped.map { Slice(category: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
        return sorted
    }

    private func color(for index: Int) -> Color {
        AppTheme.categoryColors[index % AppTheme.categoryColors.count]
    }

    private var total: Double { expenses.reduce(0) { $0 + $1.amount } }

    var body: some View {
        if expenses.isEmpty {
            EmptyStateView(
                systemImage: "chart.pie",
                title: "No Spending Yet",
                subtitle: "Add expenses to see your spending breakdown"
            )
        } else {
            VStack(spacing: 16) {
                ZStack {
                    Chart(Array(slices.enumerated()), id: \.offset) { i, slice in
                        SectorMark(
                            angle: .value("Amount", slice.amount),
                            innerRadius: .ratio(0.62),
                            angularInset: 2
                        )
                        .foregroundStyle(color(for: i))
                        .cornerRadius(4)
                    }
                    .frame(height: 200)

                    VStack(spacing: 2) {
                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                        AnimatedCurrencyText(amount: total, font: .title3.weight(.bold), compact: true)
                    }
                }

                // Legend chips
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Array(slices.enumerated()), id: \.offset) { i, slice in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(color(for: i))
                                .frame(width: 8, height: 8)
                            Text(slice.category.rawValue)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(1)
                            Spacer()
                            Text(CurrencyFormatter.formatCompact(slice.amount))
                                .font(.caption.weight(.semibold))
                                .fontDesign(.monospaced)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.surface3, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}
