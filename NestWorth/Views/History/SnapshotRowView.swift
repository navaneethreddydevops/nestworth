import SwiftUI

struct SnapshotRowView: View {
    let snapshot: NetWorthSnapshot
    let previousNetWorth: Double?

    private var delta: Double? {
        guard let prev = previousNetWorth else { return nil }
        return snapshot.netWorth - prev
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
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

            Text(CurrencyFormatter.format(snapshot.netWorth))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(snapshot.netWorth >= 0 ? Color.green : Color.red)

            HStack(spacing: 16) {
                Label {
                    Text(CurrencyFormatter.formatCompact(snapshot.totalAssets))
                        .foregroundStyle(.green)
                } icon: {
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(.green)
                }
                .font(.caption)

                Label {
                    Text(CurrencyFormatter.formatCompact(snapshot.totalLiabilities))
                        .foregroundStyle(.red)
                } icon: {
                    Image(systemName: "arrow.down.left")
                        .foregroundStyle(.red)
                }
                .font(.caption)
            }

            if !snapshot.note.isEmpty {
                Text(snapshot.note)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct DeltaBadge: View {
    let delta: Double

    private var isPositive: Bool { delta >= 0 }
    private var color: Color { delta == 0 ? .gray : (isPositive ? .green : .red) }
    private var icon: String {
        delta == 0 ? "minus" : (isPositive ? "arrow.up.right" : "arrow.down.right")
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(CurrencyFormatter.formatCompact(abs(delta)))
                .font(.caption.weight(.semibold))
                .fontDesign(.monospaced)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
    }
}
