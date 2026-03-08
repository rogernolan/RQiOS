import Testing
@testable import RQSheet

struct CharacterNotesTests {
    @Test
    func newCharacterStartsWithEmptyNotes() {
        let character = RQCharacter()

        #expect(character.notes == "")
    }
}
