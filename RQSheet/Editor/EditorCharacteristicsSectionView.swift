import SwiftUI

struct EditorCharacteristicsSectionView: View {
    @Bindable var viewModel: CharacterEditorViewModel
    @State private var expandedDiceRows: Set<CharacteristicKey> = []

    private let keys: [CharacteristicKey] = [.str, .con, .siz, .dex, .int, .pow, .cha]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(keys, id: \.self) { key in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 10) {
                        Text(key.label)
                            .foregroundStyle(.secondary)
                            .frame(width: 56, alignment: .leading)

                        TextField(
                            key.label,
                            value: Binding(
                                get: { currentValue(for: key) },
                                set: { viewModel.applyCharacteristic(key.modelCharacteristic, value: $0) }
                            ),
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 90)

                        Spacer()

                        Button {
                            toggleDiceEditor(for: key)
                        } label: {
                            Image(systemName: "dice.fill")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Edit \(key.label) with dice")
                    }

                    if expandedDiceRows.contains(key) {
                        StatDiceRollerView(key: key, viewModel: viewModel)
                    }
                }
            }
        }
    }

    private func currentValue(for key: CharacteristicKey) -> Int {
        switch key {
        case .str:
            return viewModel.character.str
        case .con:
            return viewModel.character.con
        case .siz:
            return viewModel.character.siz
        case .dex:
            return viewModel.character.dex
        case .int:
            return viewModel.character.int
        case .pow:
            return viewModel.character.pow
        case .cha:
            return viewModel.character.cha
        }
    }

    private func toggleDiceEditor(for key: CharacteristicKey) {
        if expandedDiceRows.contains(key) {
            expandedDiceRows.remove(key)
        } else {
            expandedDiceRows.insert(key)
        }
    }
}

private extension CharacteristicKey {
    var label: String {
        switch self {
        case .str:
            return "STR"
        case .con:
            return "CON"
        case .siz:
            return "SIZ"
        case .dex:
            return "DEX"
        case .int:
            return "INT"
        case .pow:
            return "POW"
        case .cha:
            return "CHA"
        }
    }
}
