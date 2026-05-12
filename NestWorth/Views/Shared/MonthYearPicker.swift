import SwiftUI

struct MonthYearPicker: View {
    @Binding var month: Int
    @Binding var year: Int
    @State private var showPicker = false

    var body: some View {
        HStack(spacing: 0) {
            Button { stepMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 36, height: 36)
            }

            Button { showPicker = true } label: {
                Text(DateHelpers.displayString(month: month, year: year))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(minWidth: 130)
                    .padding(.vertical, 8)
            }

            Button { stepMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 36, height: 36)
            }
        }
        .background(.ultraThinMaterial, in: Capsule())
        .sheet(isPresented: $showPicker) {
            MonthYearPickerSheet(month: $month, year: $year)
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
        }
    }

    private func stepMonth(by delta: Int) {
        var m = month + delta
        var y = year
        if m < 1  { m = 12; y -= 1 }
        if m > 12 { m = 1;  y += 1 }
        month = m
        year  = y
    }
}

private struct MonthYearPickerSheet: View {
    @Binding var month: Int
    @Binding var year: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Period")
                    .font(.headline)
                Spacer()
                Button("Done") { dismiss() }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.accent)
            }
            .padding()

            Divider()

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
