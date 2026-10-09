import Foundation
import SQLite3

/// Recovery files are prepared before Core Data opens or migrates the live store.
struct StoreRecovery {
    let storeURL: URL
    private var directory: URL { URL(fileURLWithPath: storeURL.path + ".recovery", isDirectory: true) }
    var hasRecoveryEvidence: Bool { FileManager.default.fileExists(atPath: directory.path) }
    var backupURL: URL { directory.appendingPathComponent("original/" + storeURL.lastPathComponent) }
    var rawURL: URL { directory.appendingPathComponent("raw/" + storeURL.lastPathComponent) }
    var markerURL: URL { directory.appendingPathComponent("verified-v2") }
    var isVerified: Bool { (try? Data(contentsOf: markerURL)) == Data("RQSchemaV2 verified".utf8) }

    func prepare() throws {
        let files = FileManager.default
        guard files.fileExists(atPath: storeURL.path), !files.fileExists(atPath: backupURL.path) else { return }
        try files.createDirectory(at: directory, withIntermediateDirectories: true)
        // Preserve raw bytes first, even if opening SQLite subsequently fails.
        if !files.fileExists(atPath: rawURL.path) {
            let staging = directory.appendingPathComponent("raw-" + UUID().uuidString)
            try files.createDirectory(at: staging, withIntermediateDirectories: true)
            try copyAssociatedFiles(to: staging, includeDatabase: true)
            try files.moveItem(at: staging, to: rawURL.deletingLastPathComponent())
        }
        let staging = directory.appendingPathComponent("preparing-" + UUID().uuidString)
        try files.createDirectory(at: staging, withIntermediateDirectories: true)
        defer { try? files.removeItem(at: staging) }
        let destination = staging.appendingPathComponent(storeURL.lastPathComponent)
        try consistentBackup(to: destination)
        try copyAssociatedFiles(to: staging, includeDatabase: false)
        try files.moveItem(at: staging, to: backupURL.deletingLastPathComponent())
    }

    func markVerified() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("RQSchemaV2 verified".utf8).write(to: markerURL, options: .atomic)
    }

    private func copyAssociatedFiles(to directory: URL, includeDatabase: Bool) throws {
        let files = FileManager.default
        let names = [storeURL.lastPathComponent + "_SUPPORT", "." + storeURL.lastPathComponent + "_SUPPORT"]
        var urls = names.map { storeURL.deletingLastPathComponent().appendingPathComponent($0) }
        if includeDatabase {
            urls += [storeURL, URL(fileURLWithPath: storeURL.path + "-wal"), URL(fileURLWithPath: storeURL.path + "-shm")]
        }
        for source in urls where files.fileExists(atPath: source.path) {
            try files.copyItem(at: source, to: directory.appendingPathComponent(source.lastPathComponent))
        }
    }

    private func consistentBackup(to destination: URL) throws {
        var source: OpaquePointer?
        var target: OpaquePointer?
        defer { sqlite3_close(source); sqlite3_close(target) }
        guard sqlite3_open_v2(storeURL.path, &source, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK,
              sqlite3_open(destination.path, &target) == SQLITE_OK,
              let backup = sqlite3_backup_init(target, "main", source, "main") else {
            throw RecoveryError.snapshotFailed
        }
        let result = sqlite3_backup_step(backup, -1)
        let finished = sqlite3_backup_finish(backup)
        guard result == SQLITE_DONE, finished == SQLITE_OK else { throw RecoveryError.snapshotFailed }
    }

    enum RecoveryError: LocalizedError {
        case snapshotFailed, incompatibleSchema, graphChanged, missingStore
        var errorDescription: String? {
            switch self {
            case .missingStore: "The character store is missing. Existing recovery evidence has been preserved; no empty store was created."
            case .snapshotFailed: "The character store could not be copied consistently. Recovery evidence has been preserved."
            case .incompatibleSchema: "The character store uses an unsupported schema. Its records have been preserved."
            case .graphChanged: "Migration could not verify every original character value and relationship. The recovery copy has been preserved."
            }
        }
    }
}
