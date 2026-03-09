import SwiftUI

struct EditorEconomySectionView: View {
    @Bindable var viewModel: CharacterEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            EditorTextFieldRow(
                label: "Income",
                placeholder: "Income",
                text: Binding(
                    get: { viewModel.character.income },
                    set: { viewModel.character.income = $0 }
                )
            )

            EditorIntegerFieldRow(
                label: "Ransom (L)",
                placeholder: "Ransom",
                value: Binding(
                    get: { viewModel.character.ransom },
                    set: { viewModel.character.ransom = $0 }
                )
            )
        }
    }
}
