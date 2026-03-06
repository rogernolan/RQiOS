import Foundation
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

    @Test
    @MainActor
    func displayFallbackUsesDashForEmptyIdentityFields() {
        let character = RQCharacter(name: "")
        character.dateOfBirth = ""
        character.family = ""
        character.patron = ""

        let viewModel = SummaryViewModel(character: character)
        #expect(viewModel.displayName == "-")
        #expect(viewModel.dateOfBirthText == "-")
        #expect(viewModel.familyText == "-")
        #expect(viewModel.patronText == "-")
    }

    @Test
    @MainActor
    func portraitStateReflectsPresenceOfPortraitData() {
        let character = RQCharacter()
        let withoutPortrait = SummaryViewModel(character: character)
        #expect(withoutPortrait.hasPortrait == false)

        character.portraitData = Data([0x00, 0x01])

        let withPortrait = SummaryViewModel(character: character)
        #expect(withPortrait.hasPortrait)
    }

    @Test
    @MainActor
    func primaryStatsExposeCharacteristicsInExpectedOrder() {
        let character = RQCharacter()
        character.str = 10
        character.con = 11
        character.siz = 12
        character.dex = 13
        character.int = 14
        character.pow = 15
        character.cha = 16

        let viewModel = SummaryViewModel(character: character)

        #expect(viewModel.primaryStats.map(\.label) == ["STR", "CON", "SIZ", "DEX", "INT", "POW", "CHA"])
        #expect(viewModel.primaryStats.map(\.value) == [10, 11, 12, 13, 14, 15, 16])
    }
}
