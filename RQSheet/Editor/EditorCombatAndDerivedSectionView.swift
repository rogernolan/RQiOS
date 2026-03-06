import SwiftUI

struct EditorCombatAndDerivedSectionView: View {
    @Bindable var viewModel: CharacterEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            EditorIntegerFieldRow(
                label: "Move",
                placeholder: "Move",
                value: Binding(
                    get: { viewModel.character.move },
                    set: { viewModel.character.move = $0 }
                )
            )

            EditorIntegerFieldRow(
                label: "Max HP",
                placeholder: "Max HP",
                value: Binding(
                    get: { viewModel.character.maxHitpoints },
                    set: { viewModel.character.maxHitpoints = $0 }
                )
            )

            EditorIntegerFieldRow(
                label: "Current HP",
                placeholder: "Current HP",
                value: Binding(
                    get: { viewModel.character.currentHitpoints },
                    set: { viewModel.character.currentHitpoints = $0 }
                )
            )

            EditorIntegerFieldRow(
                label: "Healing Rate",
                placeholder: "Healing Rate",
                value: Binding(
                    get: { viewModel.character.healingRate },
                    set: { viewModel.character.healingRate = $0 }
                )
            )
        }
    }
}
