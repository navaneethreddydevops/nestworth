import SwiftUI
import Charts

struct AssetAllocationChart: View {
    let assets: [Asset]

    private struct Slice: Identifiable {
        let id = UUID()
        let type: AssetType
        let amount: Double
        let color: Color
    }

    private var slices: [Slice] {
        let grouped = Dictionary(grouping: assets, by: \.type)
        return grouped.map { (type, items) in
            let index = AssetType.allCases.firstIndex(of: type) ?? 0
            return Slice(
                type: type,
                amount: items.reduce(0) { $0 + $1.value },
                color: AppTheme.assetColors[safe: index] ?? AppTheme.accent
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    private var total: Double { assets.reduce(0) { $0 + $1.value } }

    var body: some View {
        if assets.isEmpty {
            EmptyStateView(
                systemImage: "chart.pie",
                title: "No Assets",
                subtitle: "Add assets to see your allocation"
            )
        } else {
            HStack(alignment: .center, spacing: 16) {
                // Donut on the left
                ZStack {
                    Chart(slices) { slice in
                        SectorMark(
                            angle: .value("Value", slice.amount),
                            innerRadius: .ratio(0.60),
                            angularInset: 2
                        )
                        .foregroundStyle(slice.color)
                        .cornerRadius(4)
                    }
                    .frame(width: 160, height: 160)

                    VStack(spacing: 2) {
                        Text("TOTAL ASSETS")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(9 * 0.06)
                            .foregroundStyle(AppTheme.textTertiary)
                        AnimatedCurrencyText(amount: total, font: .system(size: 17, weight: .bold, design: .rounded), compact: true)
                    }
                }

                // Vertical legend on the right
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(slices) { slice in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(slice.color)
                                .frame(width: 8, height: 8)
                            Text(slice.type.rawValue)
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(1)
                            Spacer()
                            Text(String(format: "%.0f%%", total > 0 ? slice.amount / total * 100 : 0))
                                .font(.system(size: 12, weight: .semibold))
                                .monospacedDigit()
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
