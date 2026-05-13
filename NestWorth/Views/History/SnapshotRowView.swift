import SwiftUI

struct SnapshotRowView: View {
    let snapshot: NetWorthSnapshot
    let previousNetWorth: Double?

    private var delta: Double? {
        guard let prev = previousNetWorth else { return nil }
        return snapshot.netWorth - prev
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 4)
                .fill(isGain ? AppTheme.mint : AppTheme.coral)
                .frame(width: 4)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DateHelpers.displayString(month: snapshot.displayMonth, year: snapshot.displayYear))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    if !snapshot.note.isEmpty {
                        Text("\"\(snapshot.note)\"")
                            .font(.system(size: 11)).italic()
                            .foregroundStyle(AppTheme.textTertiary)
                            .lineLimit(1)
                    } else {
                        Text("Assets \(CurrencyFormatter.formatCompact(snapshot.totalAssets))  ·  Liab \(CurrencyFormatter.formatCompact(snapshot.totalLiabilities))")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(CurrencyFormatter.formatCompact(snapshot.netWorth))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.textPrimary)
                    if let d = delta {
                        DeltaChip(delta: d, compact: true)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .darkCard()
    }

    private var isGain: Bool {
        guard let d = delta else { return snapshot.netWorth >= 0 }
        return d >= 0
    }
}
