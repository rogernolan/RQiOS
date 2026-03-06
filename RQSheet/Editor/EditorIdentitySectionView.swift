import PhotosUI
import SwiftUI

struct EditorIdentitySectionView: View {
    @Bindable var viewModel: CharacterEditorViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            portraitEditor

            VStack(alignment: .leading, spacing: 10) {
                EditorTextFieldRow(
                    label: "Name",
                    placeholder: "Name",
                    text: Binding(
                        get: { viewModel.character.name },
                        set: { viewModel.character.name = $0 }
                    )
                )

                EditorTextFieldRow(
                    label: "Worships",
                    placeholder: "Worships",
                    text: Binding(
                        get: { viewModel.character.worships },
                        set: { viewModel.character.worships = $0 }
                    )
                )

                EditorTextFieldRow(
                    label: "Family",
                    placeholder: "Family",
                    text: Binding(
                        get: { viewModel.character.family },
                        set: { viewModel.character.family = $0 }
                    )
                )

                EditorTextFieldRow(
                    label: "Patron",
                    placeholder: "Patron",
                    text: Binding(
                        get: { viewModel.character.patron },
                        set: { viewModel.character.patron = $0 }
                    )
                )

                EditorTextFieldRow(
                    label: "Date of Birth",
                    placeholder: "Date of Birth",
                    text: Binding(
                        get: { viewModel.character.dateOfBirth },
                        set: { viewModel.character.dateOfBirth = $0 }
                    )
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

        return VStack(alignment: .center, spacing: 8) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                SummaryPortraitView(portraitData: portraitData)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change portrait")

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
