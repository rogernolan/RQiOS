import SwiftUI

struct SkillEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var percentageText: String

    let title: String
    let onSave: (String, Int) -> Void

    init(
        title: String,
        name: String = "",
        percentage: Int = 0,
        onSave: @escaping (String, Int) -> Void
    ) {
        self.title = title
        self.onSave = onSave
        _name = State(initialValue: name)
        _percentageText = State(initialValue: String(percentage.clampedPercentage))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    LabeledContent("Name") {
                        TextField("Skill name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Percentage") {
                        TextField("%", text: $percentageText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(trimmedName, parsedPercentage)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedPercentage: Int {
        Int(percentageText.filter(\.isNumber))?.clampedPercentage ?? 0
    }
}
