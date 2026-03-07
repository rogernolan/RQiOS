import SwiftData
import Testing
@testable import RQSheet

struct SummaryPersistenceIntegrationTests {
    @Test
    @MainActor
    func canInsertCharacterWithHonorAndPassionsIntoSwiftDataContainer() throws {
        let schema = Schema([
            RQCharacter.self,
            CharacterEquipmentItem.self,
            RuneAffinity.self,
            SkillDefinition.self,
            CharacterSkill.self,
            WeaponSkill.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let character = RQCharacter(name: "Arkat")
        character.ensureHonorExists().percentage = 55
        character.addPassion(description: "Loyalty (Companions)", percentage: 70)

        context.insert(character)
        try context.save()

        let results = try context.fetch(FetchDescriptor<RQCharacter>())
        #expect(results.count == 1)
        #expect(results[0].honor?.percentage == 55)
        #expect(results[0].passions.count == 1)
    }

    @Test
    @MainActor
    func canInsertCharacterWithEquipmentIntoSwiftDataContainer() throws {
        let schema = Schema([
            RQCharacter.self,
            CharacterEquipmentItem.self,
            RuneAffinity.self,
            SkillDefinition.self,
            CharacterSkill.self,
            WeaponSkill.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let character = RQCharacter(name: "Arkat")
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "Bronze", isCurrentlyEquipped: true)

        context.insert(character)
        try context.save()

        let results = try context.fetch(FetchDescriptor<RQCharacter>())
        #expect(results.count == 1)
        #expect(results[0].equipmentItems.count == 1)
        #expect(results[0].currentEncumbrance == 2)
    }
}
