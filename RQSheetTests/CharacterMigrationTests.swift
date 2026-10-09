import Foundation
import CoreData
import SwiftData
import Testing
@testable import RQSheet

struct CharacterMigrationTests {
    static let fixtureDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Fixtures/LegacyUnversioned")
    @Test @MainActor
    func frozenSchemaMatchesOriginalEntityHashes() throws {
        let data = try Data(contentsOf: Self.fixtureDirectory.appendingPathComponent("entity-hashes.json"))
        let original = try JSONDecoder().decode([String: String].self, from: data)
        let model = try #require(NSManagedObjectModel.makeManagedObjectModel(for: RQSchemaV1.schema))
        #expect(model.entityVersionHashesByName.mapValues { $0.base64EncodedString() } == original)
    }
    @Test @MainActor
    func migratesRealUnversionedStoreAndPersistsPairedRunes() throws {
        let directory = URL(fileURLWithPath: "/private/tmp/rq-migration-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("legacy.store")
        try FileManager.default.copyItem(at: Self.fixtureDirectory.appendingPathComponent("legacy.store"), to: url)
        let original = try StoreGraphSnapshot.read(url: url, schema: RQSchemaV1.schema)
        #expect(original.records.count == 22)
        do {
            let config = ModelConfiguration(schema: RQSchemaV2.schema, url: url, cloudKitDatabase: .none)
            let container = try ModelContainer(for: RQSchemaV2.schema, migrationPlan: RQMigrationPlan.self, configurations: config)
            let context = container.mainContext
            let character = try #require(context.fetch(FetchDescriptor<RQCharacter>()).first)
            #expect(character.name == "Legacy Arkat")
            #expect(character.notes == "Preserved legacy notes")
            #expect(character.portraitData == Data([0, 1, 127, 255]))
            #expect(character.allRuneAffinities.count == 16)
            #expect(character.fireAffinity?.percentage == 20)
            #expect(character.airAffinity?.percentage == 32)
            #expect(character.manAffinity?.percentage == 50)
            #expect(character.beastAffinity?.percentage == 50)
            #expect(character.manAffinity?.relatedRune === character.beastAffinity)
            let migrated = try StoreGraphSnapshot.read(url: url, schema: RQSchemaV2.schema)
            #expect(migrated.preserves(original))
            var expectedCounts = Dictionary(grouping: original.records.values, by: \.entity).mapValues(\.count)
            expectedCounts["RuneAffinity"] = 16
            #expect(Dictionary(grouping: migrated.records.values, by: \.entity).mapValues(\.count) == expectedCounts)
            character.notes = "Changed after migration"
            try context.save()
            #expect(try StoreGraphSnapshot.read(url: url, schema: RQSchemaV2.schema).preserves(original) == false)
            character.notes = "Preserved legacy notes"
            let originalFire = character.fireAffinity
            character.fireAffinity = nil
            try context.save()
            #expect(try StoreGraphSnapshot.read(url: url, schema: RQSchemaV2.schema).preserves(original) == false)
            character.fireAffinity = originalFire
            character.manAffinity?.setPercentage(73)
            try context.save()
        }
        let config = ModelConfiguration(schema: RQSchemaV2.schema, url: url, cloudKitDatabase: .none)
        let reopened = try ModelContainer(for: RQSchemaV2.schema, migrationPlan: RQMigrationPlan.self, configurations: config)
        let character = try #require(reopened.mainContext.fetch(FetchDescriptor<RQCharacter>()).first)
        #expect(character.fireAffinity?.fireCharacter === character)
        #expect(character.darknessAffinity?.darknessCharacter === character)
        #expect(character.earthAffinity?.earthCharacter === character)
        #expect(character.waterAffinity?.waterCharacter === character)
        #expect(character.airAffinity?.airCharacter === character)
        #expect(character.moonAffinity?.moonCharacter === character)
        #expect(character.manAffinity?.manCharacter === character)
        #expect(character.beastAffinity?.beastCharacter === character)
        #expect(character.manAffinity?.pairedByRune === character.beastAffinity)
        #expect(character.manAffinity?.percentage == 73)
        #expect(character.beastAffinity?.percentage == 27)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<RuneAffinity>()) == 16)
        #expect(character.honor?.percentage == 61)
        #expect(character.skills.count == 1)
        #expect(character.skills.first?.experienceCheck == true)
        #expect(character.spells.count == 2)
        #expect(character.hitLocations.count == 7)
        #expect(try StoreGraphSnapshot.read(url: url, schema: RQSchemaV2.schema).preserves(original))
        reopened.mainContext.delete(character)
        try reopened.mainContext.save()
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<RQCharacter>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<RuneAffinity>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<CharacterHitLocation>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<CharacterHonor>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<CharacterPassion>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<CharacterEquipmentItem>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<CharacterSpell>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<Weapon>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<CharacterSkill>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<SkillDefinition>()) == 1)
    }
}
