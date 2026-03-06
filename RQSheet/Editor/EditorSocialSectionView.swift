import SwiftUI

struct EditorSocialSectionView: View {
    @Bindable var viewModel: CharacterEditorViewModel

    var body: some View {
        let honor = viewModel.character.ensureHonorExists()

        return VStack(alignment: .leading, spacing: 10) {
            EditorIntegerFieldRow(
                label: "Reputation",
                placeholder: "Reputation",
                value: Binding(
                    get: { viewModel.character.reputation },
                    set: { viewModel.character.reputation = $0 }
                )
            )

            EditorTextFieldRow(
                label: "Honor",
                placeholder: "Honor description",
                text: Binding(
                    get: { honor.descriptionText },
                    set: { honor.descriptionText = $0 }
                )
            )

            EditorIntegerFieldRow(
                label: "Honor %",
                placeholder: "Honor %",
                value: Binding(
                    get: { honor.percentage },
                    set: { honor.percentage = $0 }
                )
            )

            EditorTextFieldRow(
                label: "Occupation",
                placeholder: "Occupation",
                text: Binding(
                    get: { viewModel.character.occupation },
                    set: { viewModel.character.occupation = $0 }
                )
            )

            EditorTextFieldRow(
                label: "SoL",
                placeholder: "SoL",
                text: Binding(
                    get: { viewModel.character.sol },
                    set: { viewModel.character.sol = $0 }
                )
            )
        }
    }
}
