import SwiftUI

struct SnapshotRowView: View {
    let snapshot: NetWorthSnapshot
    let previousNetWorth: Double?

    private var delta: Double? {
        guard let prev = previousNetWorth else { return nil }
        return snapshot.netWorth - prev
    }

    private var netWorthColor: Color {
        snapshot.netWorth >= 0 ? AppTheme.income : AppTheme.expense
    }

    var body: some View {
        GlassCard {
            VStack(spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(DateHelpers.displayString(month: snapshot.displayMonth, year: snapshot.displayYear))
                            .font(.headline)
                        Text(snapshot.snapshotDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let delta {
                        DeltaBadge(delta: delta)
                    }
                }

                HStack(alignment: .lastTextBaseline) {
                    AnimatedCurrencyText(
                        amount: snapshot.netWorth,
                        font: .title2.weight(.bold),
                        color: netWorthColor
                    )
                    Spacer()
                }

                Divider()

                HStack {
                    statPill(label: "Assets", amount: snapshot.totalAssets, color: AppTheme.income)
                    Spacer()
                    statPill(label: "Liabilities", amount: snapshot.totalLiabilities, color: AppTheme.expense)
                }

                if !snapshot.note.isEmpty {
                    HStack {
                        Image(systemName: "note.text")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(snapshot.note)
                            .font(.caption)
                            .italic()
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Spacer()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func statPill(label: String, amount: Double, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.formatCompact(amount))
                .font(.caption.weight(.semibold))
                .fontDesign(.monospaced)
                .foregroundStyle(color)
        }
    }
}

private struct DeltaBadge: View {
    let delta: Double

    private var isPositive: Bool { delta >= 0 }
    private var color: Color {
        delta == 0 ? .gray : (isPositive ? AppTheme.income : AppTheme.expense)
    }
    private var icon: String {
        delta == 0 ? "minus" : (isPositive ? "arrow.up.right" : "arrow.down.right")
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
            Text(CurrencyFormatter.formatCompact(abs(delta)))
                .font(.caption.weight(.semibold))
                .fontDesign(.monospaced)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12), in: Capsule())
    }
}
