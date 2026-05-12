import SwiftUI
import SwiftData

struct AddExpenseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let month: Int
    let year: Int
    var existing: ExpenseEntry? = nil

    @State private var title = ""
    @State private var amount = 0.0
    @State private var category: ExpenseCategory = .housing
    @State private var note = ""

    private var isEditing: Bool { existing != nil }
    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title (e.g. Rent)", text: $title)
                        .autocorrectionDisabled()
                }

                Section {
                    CurrencyTextField(label: "Amount", value: $amount)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { c in
                            Label(c.rawValue, systemImage: c.icon).tag(c)
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
            .navigationTitle(isEditing ? "Edit Expense" : "Add Expense")
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
        category = entry.category
        note = entry.note
    }

    private func save() {
        if let entry = existing {
            entry.title = title.trimmingCharacters(in: .whitespaces)
            entry.amount = amount
            entry.category = category
            entry.note = note
        } else {
            let entry = ExpenseEntry(
                title: title.trimmingCharacters(in: .whitespaces),
                amount: amount,
                category: category,
                month: month,
                year: year,
                note: note
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
