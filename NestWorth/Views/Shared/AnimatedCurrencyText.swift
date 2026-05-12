import SwiftUI

struct AnimatedCurrencyText: View {
    let amount: Double
    var font: Font = .title2.weight(.bold)
    var color: Color = .primary
    var compact: Bool = false

    private var formatted: String {
        compact ? CurrencyFormatter.formatCompact(amount) : CurrencyFormatter.format(amount)
    }

    var body: some View {
        Text(formatted)
            .font(font)
            .fontDesign(.monospaced)
            .foregroundStyle(color)
            .contentTransition(.numericText(value: amount))
            .animation(.spring(duration: 0.4), value: amount)
    }
}
