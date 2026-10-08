import Foundation
import SwiftData
import Testing
@testable import RQSheet

struct AppPersistenceTests {
    @Test @MainActor func defaultLocationIsUnchangedAndMemoryDisablesCloud() throws {
        #expect(AppPersistence.defaultStoreURL == ModelConfiguration(schema: Schema(RQSchemaV1.models)).url)
        let container = try AppPersistence.makeContainer(inMemory: true)
        #expect(container.configurations.first?.isStoredInMemoryOnly == true)
        #expect(container.configurations.first?.cloudKitContainerIdentifier == nil)
    }
    @Test @MainActor func legacyGraphSurvivesMigrationAndRepeatedLaunchWithUserEdits() throws {
        let url = try StoreRecoveryTests().temporaryStore()
        try FileManager.default.copyItem(at: CharacterMigrationTests.fixtureDirectory.appendingPathComponent("legacy.store"), to: url)
        let original = try StoreGraphSnapshot.read(url: url, schema: RQSchemaV1.schema)
        do {
            let container = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false)
            #expect(StoreRecovery(storeURL: url).isVerified)
            #expect(try StoreGraphSnapshot.read(url: url, schema: RQSchemaV2.schema).preserves(original))
            let character = try #require(container.mainContext.fetch(FetchDescriptor<RQCharacter>()).first)
            character.notes = "Edited after migration"
            try container.mainContext.save()
        }
        let reopened = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false)
        #expect(try reopened.mainContext.fetch(FetchDescriptor<RQCharacter>()).first?.notes == "Edited after migration")
        #expect(try StoreGraphSnapshot.read(url: StoreRecovery(storeURL: url).backupURL, schema: RQSchemaV1.schema) == original)
    }
    @Test @MainActor func missingMarkerReverifiesPartiallyMigratedStore() throws {
        let url = try StoreRecoveryTests().temporaryStore()
        try FileManager.default.copyItem(at: CharacterMigrationTests.fixtureDirectory.appendingPathComponent("legacy.store"), to: url)
        let recovery = StoreRecovery(storeURL: url)
        try recovery.prepare()
        do {
            let config = ModelConfiguration(schema: RQSchemaV2.schema, url: url, cloudKitDatabase: .none)
            _ = try ModelContainer(for: RQSchemaV2.schema, migrationPlan: RQMigrationPlan.self, configurations: config)
        }
        _ = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false)
        #expect(recovery.isVerified)
    }
    @Test @MainActor func failedOpeningNeverResetsStore() throws {
        let url = try StoreRecoveryTests().temporaryStore()
        let bytes = Data("broken original".utf8)
        try bytes.write(to: url)
        for _ in 0..<2 {
            #expect(throws: (any Error).self) { _ = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false) }
        }
        #expect(try Data(contentsOf: url) == bytes)
        #expect(!StoreRecovery(storeURL: url).isVerified)
    }
    @Test @MainActor func unverifiedChangedGraphFailsWithoutMarker() throws {
        let url = try StoreRecoveryTests().temporaryStore()
        try FileManager.default.copyItem(at: CharacterMigrationTests.fixtureDirectory.appendingPathComponent("legacy.store"), to: url)
        let recovery = StoreRecovery(storeURL: url)
        try recovery.prepare()
        do {
            let config = ModelConfiguration(schema: RQSchemaV2.schema, url: url, cloudKitDatabase: .none)
            let container = try ModelContainer(for: RQSchemaV2.schema, migrationPlan: RQMigrationPlan.self, configurations: config)
            let character = try #require(container.mainContext.fetch(FetchDescriptor<RQCharacter>()).first)
            character.notes = "Unexpected change before verification"
            try container.mainContext.save()
        }
        #expect(throws: (any Error).self) { _ = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false) }
        #expect(!recovery.isVerified)
    }

    @Test @MainActor func missingLiveStoreWithRecoveryNeverCreatesEmptyStore() throws {
        let url = try StoreRecoveryTests().temporaryStore()
        try FileManager.default.copyItem(at: CharacterMigrationTests.fixtureDirectory.appendingPathComponent("legacy.store"), to: url)
        let recovery = StoreRecovery(storeURL: url)
        try recovery.prepare()
        try FileManager.default.removeItem(at: url)
        #expect(throws: (any Error).self) { _ = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false) }
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test @MainActor func markerOnLegacySchemaCannotSkipOriginalGraphVerification() throws {
        let url = try StoreRecoveryTests().temporaryStore()
        try FileManager.default.copyItem(at: CharacterMigrationTests.fixtureDirectory.appendingPathComponent("legacy.store"), to: url)
        let recovery = StoreRecovery(storeURL: url)
        try recovery.prepare()
        try recovery.markVerified()
        do {
            let config = ModelConfiguration(schema: RQSchemaV1.schema, url: url, cloudKitDatabase: .none)
            let container = try ModelContainer(for: RQSchemaV1.schema, configurations: config)
            let character = try #require(container.mainContext.fetch(FetchDescriptor<RQSchemaV1.RQCharacter>()).first)
            character.notes = "Changed legacy records"
            try container.mainContext.save()
        }
        #expect(throws: (any Error).self) { _ = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false) }
        #expect(!recovery.isVerified)
    }

}
