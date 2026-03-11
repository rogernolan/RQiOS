import SwiftData
import SwiftUI

struct NotesView: View {
    let character: RQCharacter

    var body: some View {
        CharacterNotesContentView(character: character)
            .mainRuneBackground(runeName: "RuneTruth")
    }
}

private struct CharacterNotesContentView: View {
    @Bindable var character: RQCharacter

    private var isShowingPlaceholder: Bool {
        character.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if isShowingPlaceholder {
                Text("Add notes")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 17)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $character.notes)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(.bottom, 24)
        .background(Color(.systemBackground).opacity(0.52), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary.opacity(0.75), lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    NotesView(character: RQCharacter())
        .modelContainer(
            for: [
                RQCharacter.self,
                CharacterEquipmentItem.self,
                CharacterSpell.self,
                RuneAffinity.self,
                SkillDefinition.self,
                CharacterSkill.self,
                Weapon.self,
                CharacterHitLocation.self,
                CharacterHonor.self,
                CharacterPassion.self,
            ],
            inMemory: true
        )
}
