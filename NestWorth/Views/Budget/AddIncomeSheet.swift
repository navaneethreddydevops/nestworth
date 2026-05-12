import SwiftUI
import SwiftData

struct AddIncomeSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let month: Int
    let year: Int
    var existing: IncomeEntry? = nil

    @State private var title = ""
    @State private var amount = 0.0
    @State private var source: IncomeSource = .salary
    @State private var note = ""

    private var isEditing: Bool { existing != nil }
    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title (e.g. Salary)", text: $title)
                        .autocorrectionDisabled()
                }

                Section {
                    CurrencyTextField(label: "Amount", value: $amount)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("Source") {
                    Picker("Source", selection: $source) {
                        ForEach(IncomeSource.allCases, id: \.self) { s in
                            Label(s.rawValue, systemImage: s.icon).tag(s)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Period") {
                    LabeledContent("Month", value: DateHelpers.displayString(month: month, year: year))
                }

                Section("Note (optional)") {
                    TextField("Add a note...", text: $note, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle(isEditing ? "Edit Income" : "Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") { save() }
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    private func populateIfEditing() {
        guard let entry = existing else { return }
        title = entry.title
        amount = entry.amount
        source = entry.source
        note = entry.note
    }

    private func save() {
        if let entry = existing {
            entry.title = title.trimmingCharacters(in: .whitespaces)
            entry.amount = amount
            entry.source = source
            entry.note = note
        } else {
            let entry = IncomeEntry(
                title: title.trimmingCharacters(in: .whitespaces),
                amount: amount,
                source: source,
                month: month,
                year: year,
                note: note
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
