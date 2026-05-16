import SwiftUI

struct CurrencyTextField: View {
    let label: String
    @Binding var value: Double
    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    // Filtered binding avoids writing back to text inside onChange (feedback loop on iOS 26)
    private var filteredBinding: Binding<String> {
        Binding(
            get: { text },
            set: { raw in
                let filtered = raw.filter { $0.isNumber || $0 == "." }
                let parts = filtered.components(separatedBy: ".")
                let clean = parts.count > 2
                    ? parts[0] + "." + parts[1]
                    : filtered
                text = clean
                value = Double(clean) ?? 0
            }
        )
    }

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

                TextField("0.00", text: filteredBinding)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
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
