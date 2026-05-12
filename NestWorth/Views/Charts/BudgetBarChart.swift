import SwiftUI
import Charts

struct BudgetBarChart: View {
    let income: Double
    let expenses: Double

    private struct BarData: Identifiable {
        let id = UUID()
        let label: String
        let amount: Double
        let color: Color
    }

    private var data: [BarData] {
        [
            BarData(label: "Income",   amount: income,   color: AppTheme.income),
            BarData(label: "Expenses", amount: expenses, color: AppTheme.expense)
        ]
    }

    var body: some View {
        if income == 0 && expenses == 0 {
            Text("No data for this month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
        } else {
            Chart(data) { bar in
                BarMark(
                    x: .value("Type", bar.label),
                    y: .value("Amount", bar.amount),
                    width: .ratio(0.5)
                )
                .foregroundStyle(bar.color)
                .cornerRadius(10)
                .annotation(position: .top, alignment: .center) {
                    Text(CurrencyFormatter.formatCompact(bar.amount))
                        .font(.caption.weight(.semibold))
                        .fontDesign(.monospaced)
                        .foregroundStyle(bar.color)
                        .padding(.bottom, 2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color(uiColor: .separator).opacity(0.5))
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(CurrencyFormatter.formatCompact(v))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.caption.weight(.medium))
                        }
                    }
                }
            }
            .frame(height: 160)
        }
    }
}
