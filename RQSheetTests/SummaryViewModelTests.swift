import Testing
@testable import RQSheet

struct SummaryViewModelTests {
    @Test
    @MainActor
    func derivedStatsExposeExpectedDisplayValues() {
        let character = RQCharacter()
        character.currentHitpoints = 9
        character.maxHitpoints = 12
        character.healingRate = 3
        character.move = 8

        let viewModel = SummaryViewModel(character: character)

        #expect(viewModel.hitPointsText == "9 / 12")
        #expect(viewModel.healingRateText == "3")
        #expect(viewModel.moveText == "8")
        #expect(viewModel.groupBonuses.count == 6)
    }

    @Test
    @MainActor
    func runeRowsMarkPlaceholderStyleOnlyForFallbackRows() {
        let character = RQCharacter()

        let fallbackViewModel = SummaryViewModel(character: character)
        #expect(fallbackViewModel.topRunes.allSatisfy { $0.isPlaceholder })

        character.fireAffinity.setPercentage(30)

        let realViewModel = SummaryViewModel(character: character)
        #expect(realViewModel.topRunes.allSatisfy { $0.isPlaceholder == false })
    }
}
