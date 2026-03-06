import Foundation
import Observation

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
}
