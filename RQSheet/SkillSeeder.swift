//
//  SkillSeeder.swift
//  RQSheet
//

import Foundation
import SwiftData

enum SkillSeeder {
    @MainActor
    static func createCharacter(in context: ModelContext) -> RQCharacter {
        let character = RQCharacter()
        context.insert(character)

        ensureSkillDefinitions(in: context)
        seedSkills(for: character, in: context)

        return character
    }

    @MainActor
    private static func ensureSkillDefinitions(in context: ModelContext) {
        let existingDefinitions = (try? context.fetch(FetchDescriptor<SkillDefinition>())) ?? []
        if !existingDefinitions.isEmpty {
            return
        }

        guard let skillSeed = loadJSON(SartarSkillsSeed.self, resource: "SartarSkills") else {
            return
        }

        for (groupKey, skills) in skillSeed.skillGroups {
            guard let group = SkillGroup(rawValue: groupKey) else { continue }

            for item in skills where item.base.lowercased() != "base value" {
                let key = "\(group.rawValue)-\(slugify(item.name))"
                let definition = SkillDefinition(key: key, name: item.name, group: group, baseRule: item.base)
                context.insert(definition)
            }
        }
    }

    @MainActor
    private static func seedSkills(for character: RQCharacter, in context: ModelContext) {
        let definitions = (try? context.fetch(FetchDescriptor<SkillDefinition>())) ?? []
        for definition in definitions {
            let effective = (definition.baseValue(for: character) + character.bonus(for: definition.group)).clampedPercentage
            if effective > 0 {
                let characterSkill = CharacterSkill(character: character, definition: definition, successPercentage: 0)
                context.insert(characterSkill)
                character.skills.append(characterSkill)
                definition.characterSkills.append(characterSkill)
            }
        }
    }

    private static func slugify(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private static func loadJSON<T: Decodable>(_ type: T.Type, resource: String) -> T? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

private struct SartarSkillsSeed: Decodable {
    let skillGroups: [String: [SkillSeed]]
}

private struct SkillSeed: Decodable {
    let name: String
    let base: String
    let subgroup: String?
}
