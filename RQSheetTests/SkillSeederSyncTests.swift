import Foundation
import SwiftData
import Testing
@testable import RQSheet

struct SkillSeederSyncTests {
    @Test @MainActor
    func fillsMissingDefinitionKeysAndSeedsOnlyOneOfEachDuplicateKey() throws {
        let config = ModelConfiguration(schema: RQSchemaV2.schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: RQSchemaV2.schema, configurations: config)
        let context = container.mainContext
        let first = SkillDefinition(key: "remote-duplicate", name: "Remote", group: .knowledge, baseRule: "80")
        let second = SkillDefinition(key: "remote-duplicate", name: "Remote", group: .knowledge, baseRule: "80")
        context.insert(first); context.insert(second)
        let existingCharacter = RQCharacter(name: "Existing")
        let existingSkill = CharacterSkill(character: existingCharacter, definition: second, successPercentage: 12)
        existingCharacter.skills.append(existingSkill)
        context.insert(existingCharacter)
        let newCharacter = SkillSeeder.createCharacter(in: context)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<SkillDefinition>()) > 2)
        #expect(newCharacter.skills.filter { $0.definition?.key == "remote-duplicate" }.count == 1)
        #expect(existingSkill.definition === second)
        #expect(try context.fetchCount(FetchDescriptor<SkillDefinition>(predicate: #Predicate { $0.key == "remote-duplicate" })) == 2)
    }
}
