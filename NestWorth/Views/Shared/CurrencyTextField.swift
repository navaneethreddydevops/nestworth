import SwiftUI

struct CurrencyTextField: View {
    let label: String
    @Binding var value: Double
    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.textTertiary)

            HStack(spacing: 6) {
                Text(CurrencyFormatter.shared.currencySymbol ?? "$")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(isFocused ? AppTheme.mint : AppTheme.textTertiary)

                TextField("0.00", text: $text)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .onChange(of: text) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber || $0 == "." }
                        let parts = filtered.components(separatedBy: ".")
                        let clean = parts.count > 2 ? parts[0] + "." + parts[1] : filtered
                        value = Double(clean) ?? 0
                        guard clean != newValue else { return }
                        Task { @MainActor in text = clean }
                    }
                    .onAppear {
                        if value > 0 { text = String(format: "%.2f", value) }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.surface2, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFocused ? AppTheme.mint.opacity(0.6) : AppTheme.hairline2, lineWidth: isFocused ? 1.5 : 0.5)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
    }
}
