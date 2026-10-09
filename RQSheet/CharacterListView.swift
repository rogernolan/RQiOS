import SwiftData
import SwiftUI

struct CharacterListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RQCharacter.name) private var characters: [RQCharacter]

    @State private var pendingDeleteCharacter: RQCharacter?

    let onOpenCharacter: (RQCharacter) -> Void

    var body: some View {
        List {
            if characters.isEmpty {
                ContentUnavailableView(
                    "No Characters",
                    systemImage: "person.crop.rectangle.stack",
                    description: Text("Create a new character to open the workspace.")
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(characters) { character in
                    NavigationLink(value: character.persistentModelID) {
                        CharacterListRow(character: character)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            pendingDeleteCharacter = character
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Characters")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create New Character") {
                    createCharacter()
                }
            }
        }
        .confirmationDialog(
            "Delete character?",
            isPresented: isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                confirmDelete()
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteCharacter = nil
            }
        } message: {
            Text("This deletes the character from your synced devices and cannot be undone.")
        }
    }

    private var isShowingDeleteConfirmation: Binding<Bool> {
        Binding(
            get: { pendingDeleteCharacter != nil },
            set: { isPresented in
                if isPresented == false {
                    pendingDeleteCharacter = nil
                }
            }
        )
    }

    private func createCharacter() {
        let character = SkillSeeder.createCharacter(in: modelContext)
        try? modelContext.save()
        onOpenCharacter(character)
    }

    private func confirmDelete() {
        guard let pendingDeleteCharacter else { return }
        modelContext.delete(pendingDeleteCharacter)
        self.pendingDeleteCharacter = nil
    }
}

private struct CharacterListRow: View {
    let character: RQCharacter

    private var visibleRunes: [SummaryRuneDisplay] {
        Array(character.topSummaryRunes().prefix(3))
    }

    private var worshipsText: String? {
        let trimmed = character.worships.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var body: some View {
        HStack(spacing: 14) {
            SummaryPortraitView(
                portraitData: character.portraitData,
                width: 56,
                height: 56,
                cornerRadius: 14,
                fallbackPadding: 10
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(character.displayName)
                    .font(.headline)

                if let worshipsText {
                    Text(worshipsText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    ForEach(visibleRunes, id: \.name) { rune in
                        Image("Rune\(rune.name.rawValue)")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(rune.isPlaceholder ? .secondary : .primary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CharacterListView { _ in }
    }
    .modelContainer(try! AppPersistence.makeContainer(inMemory: true, cloudKitEnabled: false))
}
