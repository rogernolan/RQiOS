import PhotosUI
import SwiftUI

struct EditorIdentitySectionView: View {
    @Bindable var viewModel: CharacterEditorViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    private let identityLabelWidth: CGFloat = 72

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            portraitEditor

            VStack(alignment: .leading, spacing: 10) {
                EditorTextFieldRow(
                    label: "Name",
                    placeholder: "Name",
                    text: Binding(
                        get: { viewModel.character.name },
                        set: { viewModel.character.name = $0 }
                    ),
                    labelWidth: identityLabelWidth,
                    spacing: 6
                )

                EditorTextFieldRow(
                    label: "Worships",
                    placeholder: "Worships",
                    text: Binding(
                        get: { viewModel.character.worships },
                        set: { viewModel.character.worships = $0 }
                    ),
                    labelWidth: identityLabelWidth,
                    spacing: 6
                )

                EditorTextFieldRow(
                    label: "Family",
                    placeholder: "Family",
                    text: Binding(
                        get: { viewModel.character.family },
                        set: { viewModel.character.family = $0 }
                    ),
                    labelWidth: identityLabelWidth,
                    spacing: 6
                )

                EditorTextFieldRow(
                    label: "Patron",
                    placeholder: "Patron",
                    text: Binding(
                        get: { viewModel.character.patron },
                        set: { viewModel.character.patron = $0 }
                    ),
                    labelWidth: identityLabelWidth,
                    spacing: 6
                )

                EditorTextFieldRow(
                    label: "DoB",
                    placeholder: "DoB",
                    text: Binding(
                        get: { viewModel.character.dateOfBirth },
                        set: { viewModel.character.dateOfBirth = $0 }
                    ),
                    labelWidth: identityLabelWidth,
                    spacing: 6
                )
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else {
                return
            }

            Task { @MainActor in
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    viewModel.character.portraitData = data
                }
                selectedPhotoItem = nil
            }
        }
    }

    private var portraitEditor: some View {
        let portraitData = viewModel.character.portraitData

        return HStack(alignment: .top, spacing: 10) {
            Text("Portrait")
                .foregroundStyle(.secondary)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                SummaryPortraitView(portraitData: portraitData)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change portrait")

            Spacer(minLength: 0)

            Button(role: .destructive) {
                viewModel.character.portraitData = nil
            } label: {
                Label("Remove", systemImage: "trash")
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.character.portraitData == nil)
        }
    }
}
