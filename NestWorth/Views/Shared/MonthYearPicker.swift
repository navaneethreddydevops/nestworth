import SwiftUI

struct MonthYearPicker: View {
    @Binding var month: Int
    @Binding var year: Int
    @State private var showPicker = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                stepMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.1), in: Circle())
            }

            Button {
                showPicker = true
            } label: {
                Text(DateHelpers.displayString(month: month, year: year))
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(minWidth: 140)
            }

            Button {
                stepMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.1), in: Circle())
            }
        }
        .sheet(isPresented: $showPicker) {
            MonthYearPickerSheet(month: $month, year: $year)
                .presentationDetents([.height(300)])
        }
    }

    private func stepMonth(by delta: Int) {
        var m = month + delta
        var y = year
        if m < 1 { m = 12; y -= 1 }
        if m > 12 { m = 1; y += 1 }
        month = m
        year = y
    }
}

private struct MonthYearPickerSheet: View {
    @Binding var month: Int
    @Binding var year: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .padding()
            }

            HStack {
                Picker("Month", selection: $month) {
                    ForEach(1...12, id: \.self) { m in
                        Text(DateHelpers.monthName(m)).tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Year", selection: $year) {
                    ForEach(DateHelpers.availableYears(), id: \.self) { y in
                        Text(String(y)).tag(y)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
    }
}
