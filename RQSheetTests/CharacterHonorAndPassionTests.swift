import Testing
@testable import RQSheet

struct CharacterHonorAndPassionTests {
    @Test
    func ensureHonorExistsCreatesDefaultHonorOnce() {
        let character = RQCharacter()

        #expect(character.honor == nil)

        let first = character.ensureHonorExists()
        let second = character.ensureHonorExists()

        #expect(first === second)
        #expect(character.honor === first)
        #expect(first.percentage == 0)
        #expect(first.experienceCheck == false)
    }

    @Test
    func addPassionAppendsWithStableSortOrderAndClampsPercentage() {
        let character = RQCharacter()

        character.addPassion(description: "Loyalty (Sartar)", percentage: 130)
        character.addPassion(description: "Hate (Lunars)", percentage: -10)

        #expect(character.passions.count == 2)
        #expect(character.passions[0].sortOrder == 0)
        #expect(character.passions[1].sortOrder == 1)
        #expect(character.passions[0].percentage == 100)
        #expect(character.passions[1].percentage == 0)
    }
}
