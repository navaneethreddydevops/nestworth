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

    private var equityRatio: Double {
        snapshot.totalAssets > 0 ? max(0, min(snapshot.netWorth / snapshot.totalAssets, 1)) : 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header gradient band
            HStack(spacing: 12) {
                // Mini equity ring
                CircularProgressRing(
                    progress: equityRatio,
                    gradient: LinearGradient(
                        colors: [.white.opacity(0.9), .white.opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 5,
                    size: 44,
                    label: "\(Int(equityRatio * 100))%"
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(DateHelpers.displayString(month: snapshot.displayMonth, year: snapshot.displayYear))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(snapshot.snapshotDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer()
                AnimatedCurrencyText(
                    amount: snapshot.netWorth,
                    font: .system(size: 18, weight: .bold, design: .rounded),
                    color: .white
                )
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.vertical, 12)
            .background(snapshot.netWorth >= 0 ? AppTheme.netWorthGradient : AppTheme.expenseGradient)

            // Detail strip
            VStack(spacing: 10) {
                HStack {
                    statPill(icon: "building.columns.fill", label: "Assets", amount: snapshot.totalAssets, color: AppTheme.income)
                    Spacer()
                    if let delta {
                        DeltaBadge(delta: delta)
                    }
                    Spacer()
                    statPill(icon: "creditcard.fill", label: "Liabilities", amount: snapshot.totalLiabilities, color: AppTheme.expense)
                }

                if !snapshot.note.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "quote.bubble")
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
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.vertical, 12)
            .background(AppTheme.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }

    @ViewBuilder
    private func statPill(icon: String, label: String, amount: Double, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color.opacity(0.8))
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.formatCompact(amount))
                    .font(.caption.weight(.semibold))
                    .fontDesign(.monospaced)
                    .foregroundStyle(color)
            }
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
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Text(CurrencyFormatter.formatCompact(abs(delta)))
                .font(.caption2.weight(.semibold))
                .fontDesign(.monospaced)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
    }
}
