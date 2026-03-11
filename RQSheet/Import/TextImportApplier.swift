import Foundation
import SwiftData

@MainActor
enum TextImportApplier {
    static func apply(result: TextImportResult, nameOverride: String? = nil, in context: ModelContext) throws -> RQCharacter {
        let character = SkillSeeder.createCharacter(in: context)

        character.name = resolvedName(from: result, override: nameOverride)
        character.family = result.characterInfo.family ?? ""
        character.patron = result.characterInfo.patron ?? ""
        character.dateOfBirth = result.characterInfo.dateOfBirth ?? ""
        character.occupation = result.characterInfo.occupation ?? ""
        character.sol = result.characterInfo.sol ?? ""
        character.income = result.characterInfo.income ?? ""
        if let reputation = result.characterInfo.reputation {
            character.reputation = reputation
        }
        if let ransom = result.characterInfo.ransom {
            character.ransom = ransom
        }

        let worships = [result.characterInfo.cult].compactMap { $0 } + result.characterInfo.worships
        if worships.isEmpty == false {
            character.worships = worships.joined(separator: ", ")
        }

        for characteristic in RQCharacter.Characteristic.allCasesForImport {
            if let value = result.attributes[characteristic] {
                character.setCharacteristic(characteristic, to: value)
            }
        }

        for (runeName, percentage) in result.runePercentages {
            runeAffinity(for: runeName, on: character)?.setPercentage(percentage)
        }

        if let trailingNotes = result.trailingNotes?.trimmingCharacters(in: .whitespacesAndNewlines),
           trailingNotes.isEmpty == false
        {
            character.notes = trailingNotes
        }

        for passion in result.passions {
            character.addPassion(description: passion.name, percentage: passion.percentage)
        }

        for skill in result.skills {
            applySkill(skill, to: character)
        }

        for equipment in result.equipment {
            _ = character.addEquipmentItem(name: equipment)
        }

        for weapon in result.weapons {
            character.weapons.append(
                Weapon(
                    character: character,
                    name: weapon.name,
                    basePercentage: weapon.percentage ?? 0,
                    damage: weapon.damage ?? "",
                    strikeRank: weapon.strikeRank ?? "",
                    range: weapon.range ?? ""
                )
            )
        }

        for spell in result.magic {
            _ = character.addSpell(
                name: spell.name,
                points: spell.points,
                kind: spellKind(for: spell)
            )
        }

        try context.save()
        return character
    }

    private static func resolvedName(from result: TextImportResult, override: String?) -> String {
        let trimmedOverride = override?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmedOverride.isEmpty == false {
            return trimmedOverride
        }
        return result.characterInfo.candidateName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private static func applySkill(_ parsedSkill: ParsedSkillEntry, to character: RQCharacter) {
        guard let group = SkillGroup(rawValue: parsedSkill.groupName) else { return }

        if parsedSkill.isCustom == false,
           let existing = character.skills.first(where: { skill in
               skill.resolvedGroup == group &&
               skill.displayName.compare(parsedSkill.name, options: .caseInsensitive) == .orderedSame
           })
        {
            existing.setEffectiveValue(parsedSkill.percentage)
            return
        }

        _ = character.addSkill(name: parsedSkill.name, percentage: parsedSkill.percentage, group: group)
    }

    private static func spellKind(for spell: ParsedSpellEntry) -> SpellKind {
        let source = spell.source.lowercased()
        if source.contains("spirit") || source.contains("spells in mind") || source.contains("matrix spells") || source.contains("spells known") {
            return .spiritMagic
        }
        return .runeSpell
    }

    private static func runeAffinity(for rune: RuneName, on character: RQCharacter) -> RuneAffinity? {
        switch rune {
        case .fire: return character.fireAffinity
        case .darkness: return character.darknessAffinity
        case .earth: return character.earthAffinity
        case .water: return character.waterAffinity
        case .air: return character.airAffinity
        case .moon: return character.moonAffinity
        case .man: return character.manAffinity
        case .beast: return character.beastAffinity
        case .fertility: return character.fertilityAffinity
        case .death: return character.deathAffinity
        case .harmony: return character.harmonyAffinity
        case .disorder: return character.disorderAffinity
        case .truth: return character.truthAffinity
        case .illusion: return character.IllusionAffinity
        case .stasis: return character.stasisAffinity
        case .movement: return character.movementAffinity
        }
    }
}

private extension RQCharacter.Characteristic {
    static let allCasesForImport: [Self] = [.str, .con, .siz, .dex, .int, .pow, .cha]
}
