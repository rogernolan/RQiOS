import SwiftUI

struct StatDiceRollerView: View {
    let key: CharacteristicKey
    @Bindable var viewModel: CharacterEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(
                "Dice formula",
                text: Binding(
                    get: { viewModel.expressionText(for: key) },
                    set: { viewModel.setCustomExpression($0, for: key) }
                )
            )
            .textInputAutocapitalization(.never)
            .textFieldStyle(.roundedBorder)

            HStack(alignment: .center, spacing: 8) {
                Button {
                    viewModel.rollCharacteristic(key)
                } label: {
                    Label("Roll", systemImage: "die.face.6.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.rollValidationError(for: key) != nil)

                Button {
                    viewModel.applyPendingRoll(for: key)
                } label: {
                    Label("Apply", systemImage: "checkmark")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.pendingRollTotal(for: key) == nil)

                Button {
                    viewModel.clearPendingRoll(for: key)
                } label: {
                    Label("Clear", systemImage: "xmark")
                }
                .buttonStyle(.bordered)
            }

            if let error = viewModel.rollValidationError(for: key) {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            } else if let total = viewModel.pendingRollTotal(for: key) {
                Text("Pending \(key.shortLabel): \(total)")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }

            if let summary = viewModel.latestRollSummary(for: key) {
                Text(summary)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }
        .padding(10)
        .background(.thinMaterial, in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

private extension CharacteristicKey {
    var shortLabel: String {
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
