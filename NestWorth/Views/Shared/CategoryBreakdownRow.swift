import SwiftUI

struct CategoryBreakdownRow: View {
    let icon: String
    let name: String
    let color: Color
    let amount: Double
    let fraction: Double   // 0..1 relative to max category
    let count: Int
    let sharePct: Double   // 0..100

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text(CurrencyFormatter.format(amount))
                        .font(.system(size: 13, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.textPrimary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppTheme.surface3).frame(height: 4)
                        Capsule().fill(color)
                            .frame(width: max(4, geo.size.width * CGFloat(fraction)), height: 4)
                            .animation(.spring(duration: 0.5), value: fraction)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text("\(count) \(count == 1 ? "transaction" : "transactions")")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.textQuaternary)
                    Spacer()
                    Text(String(format: "%.0f%% of spend", sharePct))
                        .font(.system(size: 10))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.textQuaternary)
                }
            }
        }
    }
}
