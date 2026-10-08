import SwiftUI

struct SettingsView: View {
    let character: RQCharacter
    let onOpenCharacter: (RQCharacter) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(.title2.weight(.semibold))

                CloudSyncSettingsView()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Import Character")
                        .font(.headline)

                    Text("Paste raw RQ character text, then review what the importer found before saving a new character.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextImportView(character: character, onOpenCharacter: onOpenCharacter)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
