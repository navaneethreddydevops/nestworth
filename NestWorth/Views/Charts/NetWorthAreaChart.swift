import SwiftUI
import Charts

struct NetWorthAreaChart: View {
    let snapshots: [NetWorthSnapshot]

    private var sorted: [NetWorthSnapshot] {
        snapshots.sorted { $0.snapshotDate < $1.snapshotDate }
    }

    private var minValue: Double {
        (sorted.map(\.netWorth).min() ?? 0) * 0.95
    }

    private var maxValue: Double {
        (sorted.map(\.netWorth).max() ?? 1) * 1.05
    }

    var body: some View {
        if snapshots.isEmpty {
            EmptyStateView(
                systemImage: "chart.line.uptrend.xyaxis",
                title: "No Snapshots Yet",
                subtitle: "Save your first snapshot to start tracking net worth over time"
            )
        } else if snapshots.count == 1 {
            // Single point — show a simple stat instead of chart
            let s = sorted[0]
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DateHelpers.displayString(month: s.displayMonth, year: s.displayYear))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    AnimatedCurrencyText(
                        amount: s.netWorth,
                        font: .title.weight(.bold),
                        color: s.netWorth >= 0 ? AppTheme.income : AppTheme.expense
                    )
                }
                Spacer()
                Text("Add more snapshots to see your trend")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
            }
            .padding(.vertical, 8)
        } else {
            Chart {
                ForEach(sorted) { snapshot in
                    AreaMark(
                        x: .value("Date", snapshot.snapshotDate),
                        yStart: .value("Base", minValue),
                        yEnd: .value("Net Worth", snapshot.netWorth)
                    )
                    .foregroundStyle(AppTheme.chartGradient(AppTheme.accent))
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Date", snapshot.snapshotDate),
                        y: .value("Net Worth", snapshot.netWorth)
                    )
                    .foregroundStyle(AppTheme.accent)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", snapshot.snapshotDate),
                        y: .value("Net Worth", snapshot.netWorth)
                    )
                    .foregroundStyle(AppTheme.accent)
                    .symbolSize(30)
                }
            }
            .chartYScale(domain: minValue...maxValue)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color(uiColor: .separator).opacity(0.4))
                    AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color(uiColor: .separator).opacity(0.4))
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(CurrencyFormatter.formatCompact(v))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(height: 220)
        }
    }
}
