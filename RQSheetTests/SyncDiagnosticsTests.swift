import CloudKit
import Foundation
import Testing
@testable import RQSheet

struct SyncDiagnosticsTests {
    func directory() -> URL { FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString) }

    @Test func evictionReopensAndFreshReportIncludesOnlySafeMetadata() throws {
        let directory = directory()
        let recorder = SyncDiagnostics(directory: directory, eventLimit: 3, byteLimit: 4096)
        for _ in 0..<5 { recorder.record(.startup, stage: .started) }
        #expect(recorder.events.count == 3)
        let reopened = SyncDiagnostics(directory: directory, eventLimit: 3, byteLimit: 4096)
        #expect(reopened.events.count == 3)
        let first = try reopened.freshShareReport()
        reopened.record(.accountCheck, stage: .completed, success: true)
        let second = try reopened.freshShareReport()
        #expect(first != second)
        #expect(second.contains("iCloud.com.diffeng.RQSheet"))
        #expect(second.contains("Session:"))
        #expect(second.contains("Version:"))
        #expect(second.contains("Build:"))
        #expect(second.contains("accountCheck"))
        #expect(try Data(contentsOf: reopened.historyURL).count <= 4096)
    }

    @Test func errorsRetainCodesButNeverDescriptionsKeysOrUnknownDomains() throws {
        let marker = "PRIVATE_CHARACTER_NOTE_TOKEN"
        let underlying = NSError(domain: NSPOSIXErrorDomain, code: 13, userInfo: [NSLocalizedDescriptionKey: marker])
        let error = NSError(domain: CKErrorDomain, code: CKError.partialFailure.rawValue, userInfo: [
            NSLocalizedDescriptionKey: marker, NSUnderlyingErrorKey: underlying,
            CKPartialErrorsByItemIDKey: [marker: NSError(domain: "private." + marker, code: 77)],
            CKErrorRetryAfterKey: 12.5])
        let recorder = SyncDiagnostics(directory: directory())
        recorder.record(.cloudExport, stage: .completed, success: false, error: error)
        let report = try recorder.freshShareReport()
        #expect(!report.contains(marker))
        let summary = try #require(recorder.events.last?.error)
        #expect(summary.code == CKError.partialFailure.rawValue)
        #expect(summary.underlying.first?.code == 13)
        #expect(summary.partial.first?.code == 77)
        #expect(summary.retryAfter == 12.5)
        #expect(SyncErrorSummary(NSError(domain: CKErrorDomain, code: 1, userInfo: [CKErrorRetryAfterKey: Double.infinity])).retryAfter == nil)
    }

    @Test func corruptionAndWriteFailureKeepLoggingInMemory() throws {
        let directory = directory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("PRIVATE_CORRUPT_HISTORY".utf8).write(to: directory.appendingPathComponent("history.json"))
        let recorder = SyncDiagnostics(directory: directory)
        recorder.record(.startup, stage: .started)
        #expect(recorder.events.count == 1)
        #expect(!(try recorder.freshShareReport()).contains("PRIVATE_CORRUPT_HISTORY"))
        let blocker = directory.appendingPathComponent("file")
        try Data().write(to: blocker)
        let unwritable = SyncDiagnostics(directory: blocker)
        unwritable.record(.startup, stage: .started)
        #expect(unwritable.events.count == 1)
    }

    @Test func concurrentWritesRemainReadableAndByteBounded() throws {
        let directory = directory()
        let recorder = SyncDiagnostics(directory: directory, eventLimit: 200, byteLimit: 2048)
        DispatchQueue.concurrentPerform(iterations: 80) { _ in recorder.record(.startup, stage: .started) }
        #expect(!recorder.events.isEmpty)
        #expect(try Data(contentsOf: recorder.historyURL).count <= 2048)
        #expect(SyncDiagnostics(directory: directory, eventLimit: 200, byteLimit: 2048).events == recorder.events)
    }

    @Test func importedHistoryRejectsUnknownFieldsAndInvalidValues() throws {
        let directory = directory()
        let recorder = SyncDiagnostics(directory: directory)
        recorder.record(.startup, stage: .started)
        let data = try Data(contentsOf: recorder.historyURL)
        var object = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        object[0]["privatePayload"] = "PRIVATE_IMPORTED_MARKER"
        try JSONSerialization.data(withJSONObject: object).write(to: recorder.historyURL)
        let reopened = SyncDiagnostics(directory: directory)
        #expect(reopened.events.isEmpty)
        #expect(!(try reopened.freshShareReport()).contains("PRIVATE_IMPORTED_MARKER"))
    }
    @Test func sharePreparationIsFreshAndFailureIsSafelyRecorded() throws {
        let recorder = SyncDiagnostics(directory: directory())
        let preparation = SyncDiagnosticsSharePreparation(diagnostics: recorder)
        let first = try preparation.prepare()
        recorder.record(.startup, stage: .started)
        #expect(try preparation.prepare() != first)
        let failure = SyncDiagnosticsSharePreparation(diagnostics: recorder) {
            throw NSError(domain: "PRIVATE_EXPORT_DOMAIN", code: 42, userInfo: [NSLocalizedDescriptionKey: "PRIVATE_EXPORT_DESCRIPTION"])
        }
        #expect(throws: (any Error).self) { _ = try failure.prepare() }
        #expect(recorder.events.last?.name == .reportPreparation)
        #expect(recorder.events.last?.success == false)
        #expect(!(try recorder.freshShareReport()).contains("PRIVATE_EXPORT"))
    }

    @Test func invalidRetainedValuesAndOversizedHistoryAreDiscarded() throws {
        let directory = directory()
        let recorder = SyncDiagnostics(directory: directory)
        recorder.record(.startup, stage: .started)
        var object = try #require(JSONSerialization.jsonObject(with: Data(contentsOf: recorder.historyURL)) as? [[String: Any]])
        object[0]["schemaVersion"] = 500
        try JSONSerialization.data(withJSONObject: object).write(to: recorder.historyURL)
        #expect(SyncDiagnostics(directory: directory).events.isEmpty)
        try Data(repeating: 32, count: 256 * 1024 + 1).write(to: recorder.historyURL)
        #expect(SyncDiagnostics(directory: directory).events.isEmpty)
    }

}
