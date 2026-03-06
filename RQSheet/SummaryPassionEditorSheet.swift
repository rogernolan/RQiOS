import SwiftUI

struct SummaryPassionEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var descriptionText = ""
    @State private var percentageText = ""

    let onSave: (String, Int) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Description", text: $descriptionText)

                TextField("Percentage", text: $percentageText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Passion")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(cleanDescription, parsedPercentage)
                        dismiss()
                    }
                    .disabled(cleanDescription.isEmpty)
                }
            }
        }
    }

    private var cleanDescription: String {
        descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedPercentage: Int {
        Int(percentageText) ?? 0
    }
}
