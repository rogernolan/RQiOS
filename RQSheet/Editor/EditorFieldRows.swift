import SwiftUI

private let editorLabelWidth: CGFloat = 116

struct EditorTextFieldRow: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: editorLabelWidth, alignment: .leading)
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct EditorIntegerFieldRow: View {
    let label: String
    let placeholder: String
    @Binding var value: Int
    var alignment: TextAlignment = .leading

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: editorLabelWidth, alignment: .leading)
            TextField(placeholder, value: $value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(alignment)
                .textFieldStyle(.roundedBorder)
                .monospacedDigit()
        }
    }
}

struct EditorToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}
