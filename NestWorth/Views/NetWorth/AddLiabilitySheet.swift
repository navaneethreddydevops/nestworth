import SwiftUI
import SwiftData

struct AddLiabilitySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var existing: Liability? = nil

    @State private var name = ""
    @State private var type: LiabilityType = .creditCard
    @State private var balance = 0.0
    @State private var note = ""

    private var isEditing: Bool { existing != nil }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && balance > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name (e.g. Chase Sapphire)", text: $name)
                        .autocorrectionDisabled()
                }

                Section {
                    CurrencyTextField(label: "Outstanding Balance", value: $balance)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(LiabilityType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Note (optional)") {
                    TextField("Add a note...", text: $note, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle(isEditing ? "Edit Liability" : "Add Liability")
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
        guard let liability = existing else { return }
        name = liability.name
        type = liability.type
        balance = liability.balance
        note = liability.note
    }

    private func save() {
        if let liability = existing {
            liability.name = name.trimmingCharacters(in: .whitespaces)
            liability.type = type
            liability.balance = balance
            liability.note = note
            liability.updatedAt = Date()
        } else {
            let liability = Liability(
                name: name.trimmingCharacters(in: .whitespaces),
                type: type,
                balance: balance,
                note: note
            )
            modelContext.insert(liability)
        }
        dismiss()
    }
}
