import SwiftUI

struct TextImportView: View {
    let character: RQCharacter

    @State private var rawText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $rawText)
                .frame(minHeight: 220)
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.quaternary, lineWidth: 1)
                }

            Button("Import") {
            }
            .buttonStyle(.borderedProminent)
            .disabled(rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}
