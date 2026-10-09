import CloudKit
import Foundation
import Testing
@testable import RQSheet

@MainActor
struct SyncDiagnosticsIntegrationTests {
    func recorder() -> SyncDiagnostics { SyncDiagnostics(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)) }
    @Test func accountErrorsAndChangesAreSafeAndCoalescingKeepsItsReason() async throws {
        let recorder = recorder()
        var checks = 0
        var pending: CheckedContinuation<CKAccountStatus, Never>?
        let status = CloudSyncStatus(diagnostics: recorder) {
            checks += 1
            if checks == 1 { return await withCheckedContinuation { pending = $0 } }
            throw NSError(domain: CKErrorDomain, code: CKError.networkUnavailable.rawValue, userInfo: [NSLocalizedDescriptionKey: "PRIVATE_ACCOUNT"])
        }
        let first = Task { await status.refresh(reason: .appearance) }
        while pending == nil { await Task.yield() }
        await status.refresh(reason: .accountChange)
        pending?.resume(returning: .available)
        await first.value
        #expect(checks == 2)
        #expect(status.availability == .unknown)
        #expect(recorder.events.contains { $0.name == .accountCheck && $0.reason == .accountChange })
        #expect(recorder.events.filter { $0.name == .accountCheck && $0.stage == .completed }.map(\.account) == [.available, .unknown])
        #expect(recorder.events.last?.error?.code == CKError.networkUnavailable.rawValue)
        #expect(!(try recorder.freshShareReport()).contains("PRIVATE_ACCOUNT"))
    }
    @Test func legacyBootstrapAndVerifiedReopenHaveOrderedSafeEvents() throws {
        let url = try StoreRecoveryTests().temporaryStore()
        try FileManager.default.copyItem(at: CharacterMigrationTests.fixtureDirectory.appendingPathComponent("legacy.store"), to: url)
        let recorder = recorder()
        _ = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false, diagnostics: recorder)
        #expect(recorder.events.filter { $0.stage == .completed }.map(\.name) == [.recoveryCopy, .schemaRecognition, .localMigration, .graphVerification, .containerOpening, .startup])
        #expect(recorder.events.allSatisfy { $0.success != false })
        let firstCount = recorder.events.count
        _ = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false, diagnostics: recorder)
        let second = Array(recorder.events.dropFirst(firstCount))
        #expect(!second.contains { $0.name == .localMigration })
        #expect(second.last?.name == .startup && second.last?.success == true)
        #expect(!(try recorder.freshShareReport()).contains(url.path))
    }
    @Test func corruptStoreAndDiagnosticFileFailureDoNotChangeStartupOutcome() throws {
        let url = try StoreRecoveryTests().temporaryStore()
        let bytes = Data("PRIVATE_CORRUPT_STORE".utf8)
        try bytes.write(to: url)
        let recorder = recorder()
        #expect(throws: (any Error).self) { _ = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: false, diagnostics: recorder) }
        #expect(recorder.events.last?.name == .startup && recorder.events.last?.success == false)
        #expect(try Data(contentsOf: url) == bytes)
        #expect(!(try recorder.freshShareReport()).contains("PRIVATE_CORRUPT_STORE"))
        let blocker = url.deletingLastPathComponent().appendingPathComponent("diagnostic-file")
        try Data().write(to: blocker)
        let failedDiagnostics = SyncDiagnostics(directory: blocker)
        let validURL = try StoreRecoveryTests().temporaryStore()
        _ = try AppPersistence.makeContainer(storeURL: validURL, cloudKitEnabled: false, diagnostics: failedDiagnostics)
        #expect(failedDiagnostics.events.last?.success == true)
    }
}
