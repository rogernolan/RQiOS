//
//  SkillDefinition.swift
//  RQSheet
//

import Foundation
import SwiftData

@Model
final class SkillDefinition {
    var key: String = ""
    var name: String = ""
    var group: SkillGroup = SkillGroup.agility
    var baseRule: String = "0"

    @Relationship(deleteRule: .nullify, originalName: "characterSkills", inverse: \CharacterSkill.definition)
    private var storedCharacterSkills: [CharacterSkill]? = []
    var characterSkills: [CharacterSkill] {
        get { storedCharacterSkills ?? [] }
        set { storedCharacterSkills = newValue }
    }

    init(key: String, name: String, group: SkillGroup, baseRule: String = "0") {
        self.key = key
        self.name = name
        self.group = group
        self.baseRule = baseRule
    }

    func baseValue(for character: RQCharacter) -> Int {
        let trimmed = baseRule.trimmingCharacters(in: .whitespacesAndNewlines)

        if let number = Int(trimmed) {
            return number
        }

        if let multiplier = parseAttributeMultiplier(trimmed, attribute: "STR") {
            return character.str * multiplier
        }
        if let multiplier = parseAttributeMultiplier(trimmed, attribute: "CON") {
            return character.con * multiplier
        }
        if let multiplier = parseAttributeMultiplier(trimmed, attribute: "SIZ") {
            return character.siz * multiplier
        }
        if let multiplier = parseAttributeMultiplier(trimmed, attribute: "DEX") {
            return character.dex * multiplier
        }
        if let multiplier = parseAttributeMultiplier(trimmed, attribute: "INT") {
            return character.int * multiplier
        }
        if let multiplier = parseAttributeMultiplier(trimmed, attribute: "POW") {
            return character.pow * multiplier
        }
        if let multiplier = parseAttributeMultiplier(trimmed, attribute: "CHA") {
            return character.cha * multiplier
        }

        // For composite textual rules like "species 20 / others 00", use first numeric token.
        if let firstNumber = firstInteger(in: trimmed) {
            return firstNumber
        }

        return 0
    }

    private func parseAttributeMultiplier(_ value: String, attribute: String) -> Int? {
        let normalized = value.uppercased().replacingOccurrences(of: " ", with: "")
        guard normalized.hasPrefix("\(attribute)X") else { return nil }
        return Int(normalized.dropFirst(attribute.count + 1))
    }

    private func firstInteger(in text: String) -> Int? {
        let digits = text.split(whereSeparator: { !$0.isNumber })
        guard let first = digits.first else { return nil }
        return Int(first)
    }
}
