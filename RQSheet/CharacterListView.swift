import SwiftData
import SwiftUI

nonisolated enum CharacterPickerLayout {
    static func columnCount(for width: CGFloat) -> Int {
        width < 680 ? 1 : 2
    }
}

nonisolated enum CharacterPickerMetadata {
    static func visibleText(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func primaryGod(from worships: String) -> String? {
        worships
            .split(separator: ",", omittingEmptySubsequences: false)
            .compactMap { visibleText(String($0)) }
            .first
    }
}

struct CharacterListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RQCharacter.name) private var characters: [RQCharacter]

    @State private var pendingDeleteCharacter: RQCharacter?

    let onOpenCharacter: (RQCharacter) -> Void

    var body: some View {
        GeometryReader { geometry in
            let columnCount = CharacterPickerLayout.columnCount(for: geometry.size.width)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 16, alignment: .top), count: columnCount)

            ScrollView {
                if characters.isEmpty {
                    ContentUnavailableView(
                        "No Characters",
                        systemImage: "person.crop.rectangle.stack",
                        description: Text("Create a new character to open the workspace.")
                    )
                    .frame(maxWidth: .infinity, minHeight: max(geometry.size.height - 32, 240))
                } else {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        ForEach(characters) { character in
                            characterCard(character)
                        }
                    }
                    .padding(16)
                }
            }
            .scrollIndicators(.hidden)
        }
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

    private func characterCard(_ character: RQCharacter) -> some View {
        HStack(alignment: .top, spacing: 4) {
            NavigationLink(value: character.persistentModelID) {
                CharacterPickerCardContent(character: character)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("character.card.\(character.displayName)")

            Menu {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    pendingDeleteCharacter = character
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Actions for \(character.displayName)")
            .padding(.top, 10)
            .padding(.trailing, 10)
        }
        .background(Color(.secondarySystemGroupedBackground).opacity(0.9), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(.quaternary, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
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

private struct CharacterPickerCardContent: View {
    let character: RQCharacter

    private var visibleRunes: [SummaryRuneDisplay] {
        Array(character.topSummaryRunes().prefix(4))
    }

    private var family: String? {
        CharacterPickerMetadata.visibleText(character.family)
    }

    private var primaryGod: String? {
        CharacterPickerMetadata.primaryGod(from: character.worships)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                SummaryPortraitView(
                    portraitData: character.portraitData,
                    width: 68,
                    height: 68,
                    cornerRadius: 14,
                    fallbackPadding: 12
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(character.displayName)
                        .font(.headline)
                        .lineLimit(2)
                        .accessibilityIdentifier("character.name")

                    if let family {
                        metadataRow(label: "Family", value: family)
                    }

                    if let primaryGod {
                        metadataRow(label: "Main god", value: primaryGod)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                ForEach(visibleRunes, id: \.name) { rune in
                    Image("Rune\(rune.name.rawValue)")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(rune.isPlaceholder ? .secondary : .primary)
                        .accessibilityLabel(rune.name.rawValue)
                        .accessibilityIdentifier("character.rune.\(rune.name.rawValue)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func metadataRow(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .font(.caption)
        .lineLimit(1)
    }
}

#Preview {
    NavigationStack {
        CharacterListView { _ in }
    }
    .modelContainer(try! AppPersistence.makeContainer(inMemory: true, cloudKitEnabled: false))
}
