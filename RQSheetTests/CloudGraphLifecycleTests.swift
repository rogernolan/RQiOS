import Foundation
import SwiftData
import Testing
@testable import RQSheet

struct CloudGraphLifecycleTests {
    @MainActor private func container() throws -> ModelContainer {
        let config = ModelConfiguration(schema: RQSchemaV2.schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return try ModelContainer(for: RQSchemaV2.schema, configurations: config)
    }

    @Test @MainActor
    func explicitCreationInitializesTheCompleteOwnedGraph() throws {
        let character = RQCharacter()
        #expect(character.allRuneAffinities.count == 16)
        #expect(character.honor != nil)
        #expect(character.hitLocations.count == 7)
        #expect(character.manAffinity?.relatedRune === character.beastAffinity)
    }

    @Test @MainActor
    func missingRuneAndHonorLinksDoNotGenerateChildrenDuringReads() throws {
        let container = try container()
        let context = container.mainContext
        let character = RQCharacter()
        character.fireAffinity = nil
        character.manAffinity = nil
        character.honor = nil
        context.insert(character)
        try context.save()
        let runeCount = try context.fetchCount(FetchDescriptor<RuneAffinity>())
        let honorCount = try context.fetchCount(FetchDescriptor<CharacterHonor>())
        #expect(character.allRuneAffinities.count == 14)
        _ = character.topSummaryRunes()
        _ = character.honor?.percentage ?? 0
        try context.save()
        #expect(character.fireAffinity == nil)
        #expect(character.manAffinity == nil)
        #expect(character.honor == nil)
        #expect(try context.fetchCount(FetchDescriptor<RuneAffinity>()) == runeCount)
        #expect(try context.fetchCount(FetchDescriptor<CharacterHonor>()) == honorCount)
    }

    @Test @MainActor
    func deletingCharacterCascadesOwnedGraphAndPreservesSharedDefinition() throws {
        let container = try container()
        let context = container.mainContext
        let owner = RQCharacter(name: "Delete")
        owner.addPassion(description: "Clan", percentage: 60)
        _ = owner.addEquipmentItem(name: "Bag")
        _ = owner.addSpell(name: "Heal", kind: .spiritMagic)
        owner.weapons.append(Weapon(character: owner, name: "Sword"))
        let definition = SkillDefinition(key: "shared", name: "Shared", group: .knowledge)
        let survivor = RQCharacter(name: "Keep")
        let first = CharacterSkill(character: owner, definition: definition)
        let second = CharacterSkill(character: survivor, definition: definition)
        owner.skills.append(first); survivor.skills.append(second)
        context.insert(owner); context.insert(survivor)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<RuneAffinity>()) == 32)
        context.delete(owner)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<RQCharacter>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<RuneAffinity>()) == 16)
        #expect(try context.fetchCount(FetchDescriptor<CharacterHitLocation>()) == 7)
        #expect(try context.fetchCount(FetchDescriptor<CharacterHonor>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<CharacterPassion>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<CharacterEquipmentItem>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<CharacterSpell>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Weapon>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<CharacterSkill>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<SkillDefinition>()) == 1)
        #expect(second.definition === definition)
        #expect(survivor.manAffinity?.relatedRune === survivor.beastAffinity)
    }
}
