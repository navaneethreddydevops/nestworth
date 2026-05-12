import SwiftUI

struct CurrencyTextField: View {
    let label: String
    @Binding var value: Double
    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Text(CurrencyFormatter.shared.currencySymbol ?? "$")
                    .font(.body)
                    .foregroundStyle(isFocused ? .blue : .secondary)

                TextField("0.00", text: $text)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .font(.system(.body, design: .monospaced))
                    .onChange(of: text) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber || $0 == "." }
                        if filtered != newValue {
                            text = filtered
                        }
                        let parts = filtered.components(separatedBy: ".")
                        if parts.count > 2 {
                            text = parts[0] + "." + parts[1...].joined()
                        }
                        value = Double(text) ?? 0
                    }
                    .onAppear {
                        if value > 0 {
                            text = String(format: "%.2f", value)
                        }
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isFocused ? Color.blue : Color(uiColor: .separator),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
        }
    }
}
