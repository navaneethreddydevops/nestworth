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
            VStack(spacing: 16) {
                ZStack {
                    Chart(slices) { slice in
                        SectorMark(
                            angle: .value("Value", slice.amount),
                            innerRadius: .ratio(0.62),
                            angularInset: 2
                        )
                        .foregroundStyle(slice.color)
                        .cornerRadius(4)
                    }
                    .frame(height: 200)

                    VStack(spacing: 2) {
                        Text("Assets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        AnimatedCurrencyText(amount: total, font: .title3.weight(.bold), compact: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(slices) { slice in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(slice.color)
                                .frame(width: 8, height: 8)
                            Text(slice.type.rawValue)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Spacer()
                            Text(CurrencyFormatter.formatCompact(slice.amount))
                                .font(.caption.weight(.semibold))
                                .fontDesign(.monospaced)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.surfaceTertiary, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
