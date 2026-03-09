import SwiftUI

struct EditorCombatAndDerivedSectionView: View {
    @Bindable var viewModel: CharacterEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            EditorTextFieldRow(
                label: "Move",
                placeholder: "Move",
                text: Binding(
                    get: { viewModel.character.move.map(String.init) ?? "" },
                    set: { newValue in
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.isEmpty == false else {
                            viewModel.character.move = nil
                            return
                        }

                        if let value = Int(trimmed.filter(\.isNumber)) {
                            viewModel.character.move = max(1, value)
                        }
                    }
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
