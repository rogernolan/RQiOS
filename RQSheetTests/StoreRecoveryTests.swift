import Foundation
import SQLite3
import Testing
@testable import RQSheet

struct StoreRecoveryTests {
    func temporaryStore() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("default.store")
    }
    @Test func snapshotIncludesCommittedWALAndExcludesUncommittedRows() throws {
        let url = try temporaryStore()
        var db: OpaquePointer?
        #expect(sqlite3_open(url.path, &db) == SQLITE_OK)
        defer { sqlite3_close(db) }
        #expect(sqlite3_exec(db, "PRAGMA journal_mode=WAL; PRAGMA wal_autocheckpoint=0; CREATE TABLE records(value); INSERT INTO records VALUES(1); BEGIN; INSERT INTO records VALUES(2);", nil, nil, nil) == SQLITE_OK)
        let support = url.deletingLastPathComponent().appendingPathComponent(".default.store_SUPPORT")
        try FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        try Data([3, 4]).write(to: support.appendingPathComponent("blob"))
        let recovery = StoreRecovery(storeURL: url)
        try recovery.prepare()
        var backup: OpaquePointer?
        #expect(sqlite3_open(recovery.backupURL.path, &backup) == SQLITE_OK)
        defer { sqlite3_close(backup) }
        var statement: OpaquePointer?
        #expect(sqlite3_prepare_v2(backup, "SELECT COUNT(*) FROM records", -1, &statement, nil) == SQLITE_OK)
        defer { sqlite3_finalize(statement) }
        #expect(sqlite3_step(statement) == SQLITE_ROW)
        #expect(sqlite3_column_int(statement, 0) == 1)
        #expect(try Data(contentsOf: recovery.backupURL.deletingLastPathComponent().appendingPathComponent(".default.store_SUPPORT/blob")) == Data([3, 4]))
        let original = try Data(contentsOf: recovery.backupURL)
        #expect(sqlite3_exec(db, "ROLLBACK; INSERT INTO records VALUES(3)", nil, nil, nil) == SQLITE_OK)
        try recovery.prepare()
        #expect(try Data(contentsOf: recovery.backupURL) == original)
    }
    @Test func corruptedStorePreservesRawEvidenceWithoutMarker() throws {
        let url = try temporaryStore()
        let bytes = Data("not sqlite".utf8)
        try bytes.write(to: url)
        try Data([8, 9]).write(to: URL(fileURLWithPath: url.path + "-wal"))
        let recovery = StoreRecovery(storeURL: url)
        #expect(throws: (any Error).self) { try recovery.prepare() }
        #expect(try Data(contentsOf: url) == bytes)
        #expect(try Data(contentsOf: recovery.rawURL) == bytes)
        #expect(try Data(contentsOf: URL(fileURLWithPath: recovery.rawURL.path + "-wal")) == Data([8, 9]))
        #expect(!recovery.isVerified)
    }
}
