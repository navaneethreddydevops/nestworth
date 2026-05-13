import SwiftUI

struct DeltaChip: View {
    let delta: Double
    var compact: Bool = false

    private var isPositive: Bool { delta >= 0 }
    private var isZero: Bool     { delta == 0 }
    private var color: Color {
        isZero ? AppTheme.textTertiary : (isPositive ? AppTheme.mint : AppTheme.coral)
    }
    private var icon: String {
        isZero ? "minus" : (isPositive ? "arrow.up.right" : "arrow.down.right")
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(compact
                 ? CurrencyFormatter.formatCompact(abs(delta))
                 : "\(isPositive && !isZero ? "+" : "")\(CurrencyFormatter.formatCompact(delta))")
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12), in: Capsule())
        .overlay(Capsule().stroke(color.opacity(0.28), lineWidth: 0.5))
    }
}
