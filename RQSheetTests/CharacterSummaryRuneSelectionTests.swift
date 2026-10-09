import Testing
@testable import RQSheet

struct CharacterSummaryRuneSelectionTests {
    @Test
    func topSummaryRunesReturnsHighestFourWhenNonZeroValuesExist() {
        let character = RQCharacter()
        character.fireAffinity?.setPercentage(72)
        character.airAffinity?.setPercentage(51)
        character.moonAffinity?.setPercentage(49)
        character.darknessAffinity?.setPercentage(61)
        character.truthAffinity?.setPercentage(81)

        let runes = character.topSummaryRunes()

        #expect(runes.count == 4)
        #expect(runes.map(\.name) == [.truth, .fire, .darkness, .air])
        #expect(runes.allSatisfy { $0.isPlaceholder == false })
    }

    @Test
    func topSummaryRunesPersistsPlaceholderSetWhenAllRunesAreZero() {
        let character = RQCharacter()

        let first = character.topSummaryRunes().map(\.name)
        let second = character.topSummaryRunes().map(\.name)

        #expect(first.count == 4)
        #expect(Set(first).count == 4)
        #expect(first == second)
    }

    @Test
    func topSummaryRunesMarksOnlyFallbackAsPlaceholder() {
        let character = RQCharacter()

        let placeholderRunes = character.topSummaryRunes()

        character.fireAffinity?.setPercentage(80)
        let realRunes = character.topSummaryRunes()

        #expect(placeholderRunes.allSatisfy { $0.isPlaceholder })
        #expect(realRunes.allSatisfy { $0.isPlaceholder == false })
    }
}
