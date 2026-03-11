import Testing
@testable import RQSheet

struct CharacterDisplayNameTests {
    @Test
    func displayNameFallsBackWhenBlank() {
        let character = RQCharacter(name: "   ")

        #expect(character.displayName == "Unnamed Character")
    }

    @Test
    func displayNameTrimsWhitespace() {
        let character = RQCharacter(name: "  Beriqet  ")

        #expect(character.displayName == "Beriqet")
    }
}
