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
        character.pow = 11
        character.currentMagicPoints = 7
        character.runePoints = 4

        let viewModel = SummaryViewModel(character: character)

        #expect(viewModel.hitPointsText == "9 / 12")
        #expect(viewModel.healingRateText == "3")
        #expect(viewModel.moveText == "8")
        #expect(viewModel.isMoveFallback == false)
        #expect(viewModel.magicPointsText == "7 / 11")
        #expect(viewModel.runePointsText == "4")
        #expect(viewModel.skillBonuses.count == 7)
    }

    @Test
    @MainActor
    func missingMoveFallsBackToEight() {
        let character = RQCharacter()
        character.move = nil

        let viewModel = SummaryViewModel(character: character)

        #expect(viewModel.moveText == "8")
        #expect(viewModel.isMoveFallback)
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

    @Test
    @MainActor
    func encumbranceDisplayUsesCharacterTotals() {
        let character = RQCharacter()
        character.str = 12
        character.con = 16
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Torch", encumbrance: 1, notes: "", isCurrentlyEquipped: false)
        character.weapons.append(Weapon(name: "Broadsword", damage: "1d8+1", enc: 1, isEquipped: true))
        character.weapons.append(Weapon(name: "Dagger", damage: "1d4+2", enc: 1, isEquipped: false))

        let viewModel = SummaryViewModel(character: character)

        #expect(viewModel.encumbranceText == "12/3")
        #expect(viewModel.isEncumbranceOverLimit == false)
    }

    @Test
    @MainActor
    func encumbranceOverflowIsDetectedWhenCurrentExceedsMax() {
        let character = RQCharacter()
        character.str = 8
        character.con = 12
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 5, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Pack", encumbrance: 4, notes: "", isCurrentlyEquipped: true)
        character.weapons.append(Weapon(name: "Longsword", damage: "1d8+1", enc: 1, isEquipped: true))

        let viewModel = SummaryViewModel(character: character)

        #expect(viewModel.encumbranceText == "8/10")
        #expect(viewModel.isEncumbranceOverLimit)
    }

    @Test
    @MainActor
    func damageBonusUsesStrengthAndSizeBands() {
        let under = RQCharacter()
        under.str = 6
        under.siz = 6
        #expect(SummaryViewModel(character: under).damageBonusText == "-1D4")

        let none = RQCharacter()
        none.str = 12
        none.siz = 12
        #expect(SummaryViewModel(character: none).damageBonusText == "-")

        let quarter = RQCharacter()
        quarter.str = 12
        quarter.siz = 13
        #expect(SummaryViewModel(character: quarter).damageBonusText == "+1D4")

        let d6 = RQCharacter()
        d6.str = 17
        d6.siz = 16
        #expect(SummaryViewModel(character: d6).damageBonusText == "+1D6")

        let twoD6 = RQCharacter()
        twoD6.str = 21
        twoD6.siz = 20
        #expect(SummaryViewModel(character: twoD6).damageBonusText == "+2D6")

        let threeD6 = RQCharacter()
        threeD6.str = 29
        threeD6.siz = 28
        #expect(SummaryViewModel(character: threeD6).damageBonusText == "+3D6")
    }
}
