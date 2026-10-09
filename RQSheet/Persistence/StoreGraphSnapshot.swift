import CoreData
import SwiftData
import Foundation

/// Reads a consistent store with no active writers. It creates no app models
/// and does not repair missing links.
/// Object identities and original property names let an upgrade verify every
/// previously persisted value and relationship even when V2 adds new records.
struct StoreGraphSnapshot: Equatable {
    struct Record: Equatable {
        let entity: String
        let attributes: [String: String]
        let relationships: [String: [String]]
    }
    let records: [String: Record]

    @MainActor
    static func read(url: URL, schema: Schema) throws -> StoreGraphSnapshot {
        guard let model = NSManagedObjectModel.makeManagedObjectModel(for: schema) else {
            throw CocoaError(.persistentStoreInvalidType)
        }
        // A checkpointed WAL database cannot always bootstrap a read-only SQLite
        // connection without sidecars. Open an isolated copy instead, without saves.
        // The caller must supply a consistent store (for example the recovery copy).
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("RQGraphSnapshot-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let scratchURL = directory.appendingPathComponent(url.lastPathComponent)
        try FileManager.default.copyItem(at: url, to: scratchURL)
        for suffix in ["-wal", "_SUPPORT"] {
            let source = URL(fileURLWithPath: url.path + suffix)
            if FileManager.default.fileExists(atPath: source.path) {
                try FileManager.default.copyItem(at: source, to: URL(fileURLWithPath: scratchURL.path + suffix))
            }
        }
        let hiddenSupport = url.deletingLastPathComponent().appendingPathComponent("." + url.lastPathComponent + "_SUPPORT")
        if FileManager.default.fileExists(atPath: hiddenSupport.path) {
            try FileManager.default.copyItem(at: hiddenSupport, to: directory.appendingPathComponent(hiddenSupport.lastPathComponent))
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = try coordinator.addPersistentStore(type: .sqlite, at: scratchURL, options: [NSPersistentHistoryTrackingKey: true])
        defer { try? coordinator.remove(store) }
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        var records: [String: Record] = [:]
        for entity in model.entities {
            guard let name = entity.name else { continue }
            let request = NSFetchRequest<NSManagedObject>(entityName: name)
            for object in try context.fetch(request) {
                var attributes: [String: String] = [:]
                for attribute in entity.attributesByName.values {
                    let key = attribute.renamingIdentifier ?? attribute.name
                    let value = object.value(forKey: attribute.name)
                    if let data = value as? Data { attributes[key] = "data:" + data.base64EncodedString() }
                    else if let value { attributes[key] = String(reflecting: value) }
                    else { attributes[key] = "nil" }
                }
                var relationships: [String: [String]] = [:]
                for relationship in entity.relationshipsByName.values {
                    let key = relationship.renamingIdentifier ?? relationship.name
                    let value = object.value(forKey: relationship.name)
                    let linked: [NSManagedObject]
                    if let object = value as? NSManagedObject { linked = [object] }
                    else if let objects = value as? Set<NSManagedObject> { linked = Array(objects) }
                    else if let objects = value as? NSOrderedSet { linked = objects.array.compactMap { $0 as? NSManagedObject } }
                    else { linked = [] }
                    relationships[key] = linked.map { $0.objectID.uriRepresentation().absoluteString }.sorted()
                }
                records[object.objectID.uriRepresentation().absoluteString] = Record(entity: name, attributes: attributes, relationships: relationships)
            }
        }
        return StoreGraphSnapshot(records: records)
    }

    /// Additional migration-created fields/records are allowed, but no original
    /// stored value, link, identity, or record may disappear or change.
    func preserves(_ original: StoreGraphSnapshot) -> Bool {
        for (identity, previous) in original.records {
            guard let current = records[identity], current.entity == previous.entity else { return false }
            for (key, value) in previous.attributes where current.attributes[key] != value { return false }
            for (key, value) in previous.relationships where current.relationships[key] != value { return false }
        }
        return true
    }
}
