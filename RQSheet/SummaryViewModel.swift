import Foundation
import Observation

struct CharacteristicStatDisplay: Equatable {
    let label: String
    let value: Int
}

@MainActor
@Observable
final class SummaryViewModel {
    let character: RQCharacter

    init(character: RQCharacter) {
        self.character = character
    }

    var topRunes: [SummaryRuneDisplay] {
        character.topSummaryRunes()
    }

    var hitPointsText: String {
        "\(character.currentHitpoints) / \(character.maxHitpoints)"
    }

    var healingRateText: String {
        "\(character.healingRate)"
    }

    var moveText: String {
        "\(character.move)"
    }

    var encumbranceText: String {
        "\(character.maxEncumbrance)/\(character.currentEncumbrance)"
    }

    var displayName: String {
        display(character.name)
    }

    var dateOfBirthText: String {
        display(character.dateOfBirth)
    }

    var familyText: String {
        display(character.family)
    }

    var patronText: String {
        display(character.patron)
    }

    var hasPortrait: Bool {
        character.portraitData?.isEmpty == false
    }

    var primaryStats: [CharacteristicStatDisplay] {
        [
            CharacteristicStatDisplay(label: "STR", value: character.str),
            CharacteristicStatDisplay(label: "CON", value: character.con),
            CharacteristicStatDisplay(label: "SIZ", value: character.siz),
            CharacteristicStatDisplay(label: "DEX", value: character.dex),
            CharacteristicStatDisplay(label: "INT", value: character.int),
            CharacteristicStatDisplay(label: "POW", value: character.pow),
            CharacteristicStatDisplay(label: "CHA", value: character.cha),
        ]
    }

    var groupBonuses: [(name: String, value: Int)] {
        SkillGroup.allCases.map { group in
            (name: groupTitle(for: group), value: character.bonus(for: group))
        }
    }

    private func groupTitle(for group: SkillGroup) -> String {
        switch group {
        case .agility:
            return "Agility"
        case .communication:
            return "Communication"
        case .knowledge:
            return "Knowledge"
        case .manipulation:
            return "Manipulation"
        case .perception:
            return "Perception"
        case .stealth:
            return "Stealth"
        }
    }

    private func display(_ value: String) -> String {
        value.isEmpty ? "-" : value
    }
}
