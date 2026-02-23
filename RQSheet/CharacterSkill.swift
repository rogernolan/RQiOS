//
//  CharacterSkill.swift
//  RQSheet
//

import Foundation
import SwiftData

@Model
final class CharacterSkill {
    var character: RQCharacter?

    var definition: SkillDefinition?

    private(set) var successPercentage: Int
    var experienceCheck: Bool

    init(character: RQCharacter? = nil, definition: SkillDefinition? = nil, successPercentage: Int = 0, experienceCheck: Bool = false) {
        self.character = character
        self.definition = definition
        self.successPercentage = successPercentage
        self.experienceCheck = experienceCheck
    }

    func effectiveValue() -> Int {
        guard let character, let definition else {
            return successPercentage.clampedPercentage
        }
        let base = definition.baseValue(for: character)
        let categoryBonus = character.bonus(for: definition.group)
        return (base + categoryBonus + successPercentage).clampedPercentage
    }

    func setEffectiveValue(_ newValue: Int) {
        guard let character, let definition else {
            successPercentage = newValue.clampedPercentage
            return
        }
        let clampedTarget = newValue.clampedPercentage
        let dynamicPart = definition.baseValue(for: character) + character.bonus(for: definition.group)
        successPercentage = clampedTarget - dynamicPart
    }
}
