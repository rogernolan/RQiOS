import CoreData
import Foundation
import SwiftData

@MainActor
enum AppPersistence {
    static let cloudKitContainerIdentifier = "iCloud.com.diffeng.RQSheet"
    static var defaultStoreURL: URL { ModelConfiguration(schema: RQSchemaV2.schema).url }

    static func makeContainer(storeURL: URL? = nil, inMemory: Bool = false, cloudKitEnabled: Bool = true) throws -> ModelContainer {
        if inMemory {
            return try ModelContainer(for: RQSchemaV2.schema, migrationPlan: RQMigrationPlan.self,
                configurations: ModelConfiguration(schema: RQSchemaV2.schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        }
        let url = storeURL ?? defaultStoreURL
        let recovery = StoreRecovery(storeURL: url)
        let existed = FileManager.default.fileExists(atPath: url.path)
        if !existed && recovery.hasRecoveryEvidence { throw StoreRecovery.RecoveryError.missingStore }
        if existed {
            try recovery.prepare()
            let schema = try compatibleSchema(at: url)
            if recovery.isVerified && schema.version != RQSchemaV2.schema.version {
                try FileManager.default.removeItem(at: recovery.markerURL)
            }
        }
        if !recovery.isVerified {
            let original: StoreGraphSnapshot?
            if FileManager.default.fileExists(atPath: recovery.backupURL.path) {
                original = try StoreGraphSnapshot.read(url: recovery.backupURL, schema: compatibleSchema(at: recovery.backupURL))
            } else { original = nil }
            // End the local container's lifetime before opening the CloudKit container.
            try migrateLocally(at: url)
            let migrated = try StoreGraphSnapshot.read(url: url, schema: RQSchemaV2.schema)
            if let original, !migrated.preserves(original) { throw StoreRecovery.RecoveryError.graphChanged }
        }
        let configuration = ModelConfiguration(schema: RQSchemaV2.schema, url: url,
            cloudKitDatabase: cloudKitEnabled ? .private(cloudKitContainerIdentifier) : .none)
        let container = try ModelContainer(for: RQSchemaV2.schema, migrationPlan: RQMigrationPlan.self, configurations: configuration)
        if !recovery.isVerified { try recovery.markVerified() }
        return container
    }

    private static func migrateLocally(at url: URL) throws {
        let configuration = ModelConfiguration(schema: RQSchemaV2.schema, url: url, cloudKitDatabase: .none)
        let container = try ModelContainer(for: RQSchemaV2.schema, migrationPlan: RQMigrationPlan.self, configurations: configuration)
        try container.mainContext.save()
    }

    private static func compatibleSchema(at url: URL) throws -> Schema {
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(type: .sqlite, at: url, options: nil)
        for schema in [RQSchemaV2.schema, RQSchemaV1.schema] {
            if let model = NSManagedObjectModel.makeManagedObjectModel(for: schema),
               model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) { return schema }
        }
        throw StoreRecovery.RecoveryError.incompatibleSchema
    }
}
