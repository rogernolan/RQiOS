import SwiftUI

struct EditorPassionsSectionView: View {
    @Bindable var viewModel: CharacterEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let passions = viewModel.sortedPassions
            if passions.isEmpty {
                Text("No passions yet.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(passions.indices, id: \.self) { index in
                        let passion = passions[index]
                        passionRow(passion: passion, index: index, count: passions.count)
                    }
                }
            }

            HStack(alignment: .center, spacing: 8) {
                Button {
                    viewModel.addPassion(description: "", percentage: 0)
                } label: {
                    Label("Add Passion", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                Spacer()
            }
        }
    }

    private func passionRow(passion: CharacterPassion, index: Int, count: Int) -> some View {
        HStack(alignment: .center, spacing: 8) {
            TextField(
                "Description",
                text: Binding(
                    get: { passion.descriptionText },
                    set: { viewModel.updatePassion(passion, description: $0, percentage: passion.percentage) }
                )
            )
            .textFieldStyle(.roundedBorder)

            TextField(
                "%",
                value: Binding(
                    get: { passion.percentage },
                    set: { viewModel.updatePassion(passion, description: passion.descriptionText, percentage: $0) }
                ),
                format: .number
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .monospacedDigit()
            .textFieldStyle(.roundedBorder)
            .frame(width: 72)

            HStack(alignment: .center, spacing: 4) {
                compactArrowButton(
                    systemImage: "arrow.up",
                    accessibilityLabel: "Move passion up",
                    disabled: index == 0
                ) {
                    movePassionUp(at: index)
                }

                compactArrowButton(
                    systemImage: "arrow.down",
                    accessibilityLabel: "Move passion down",
                    disabled: index == count - 1
                ) {
                    movePassionDown(at: index)
                }
            }

            Button(role: .destructive) {
                viewModel.deletePassions(at: IndexSet(integer: index))
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Delete passion")
        }
    }

    private func movePassionUp(at index: Int) {
        guard index > 0 else {
            return
        }

        viewModel.movePassions(from: IndexSet(integer: index), to: index - 1)
    }

    private func movePassionDown(at index: Int) {
        let count = viewModel.sortedPassions.count
        guard index < count - 1 else {
            return
        }

        viewModel.movePassions(from: IndexSet(integer: index), to: index + 2)
    }

    private func compactArrowButton(
        systemImage: String,
        accessibilityLabel: String,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: systemImage)
                .font(.caption)
                .frame(width: 22, height: 22)
                .background(.thinMaterial, in: .rect(cornerRadius: 6))
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.quaternary, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(accessibilityLabel)
    }
}
