import CloudKit
import CoreData
import Foundation
import Testing
@testable import RQSheet

struct CloudSyncEventMonitorTests {
    @Test func startStopAreIdempotentAndMalformedNotificationsAreIgnored() {
        let center = NotificationCenter()
        let recorder = SyncDiagnostics(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        let monitor = CloudSyncEventMonitor(center: center, diagnostics: recorder)
        #expect(!monitor.isRunning)
        monitor.start(); monitor.start()
        #expect(monitor.isRunning)
        center.post(name: NSPersistentCloudKitContainer.eventChangedNotification, object: nil, userInfo: [NSPersistentCloudKitContainer.eventNotificationUserInfoKey: "PRIVATE_BAD_EVENT"])
        #expect(recorder.events.isEmpty)
        monitor.stop(); monitor.stop()
        #expect(!monitor.isRunning)
        monitor.start()
        #expect(monitor.isRunning)
    }
    @Test func mapsSafeEventFieldsAndFiniteDuration() throws {
        let recorder = SyncDiagnostics(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        let monitor = CloudSyncEventMonitor(center: NotificationCenter(), diagnostics: recorder)
        let start = Date(timeIntervalSince1970: 100)
        for type in [NSPersistentCloudKitContainer.EventType.setup, .import, .export] {
            monitor.record(type: type, start: start, end: nil, succeeded: false, error: nil)
            monitor.record(type: type, start: start, end: start.addingTimeInterval(2), succeeded: true, error: nil)
        }
        #expect(recorder.events.map(\.name) == [.cloudSetup, .cloudSetup, .cloudImport, .cloudImport, .cloudExport, .cloudExport])
        #expect(recorder.events.map(\.stage) == [.started, .completed, .started, .completed, .started, .completed])
        #expect(recorder.events.first?.success == nil)
        #expect(recorder.events.last?.success == true)
        #expect(recorder.events.last?.duration == 2)
        monitor.record(type: .export, start: start, end: start.addingTimeInterval(1), succeeded: false, error: NSError(domain: "PRIVATE_DOMAIN", code: 99, userInfo: [NSLocalizedDescriptionKey: "PRIVATE_NOTE"]))
        #expect(recorder.events.last?.error?.code == 99)
        #expect(!(try recorder.freshShareReport()).contains("PRIVATE_"))
    }
    @Test func accountChangesAreObservedWithoutSettingsAndStopWithTheMonitor() throws {
        let center = NotificationCenter()
        let recorder = SyncDiagnostics(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        let monitor = CloudSyncEventMonitor(center: center, diagnostics: recorder)
        monitor.start(); monitor.start()
        center.post(name: .CKAccountChanged, object: "PRIVATE_ACCOUNT", userInfo: ["PRIVATE_ACCOUNT": "PRIVATE_TOKEN"])
        #expect(recorder.events.count == 1)
        #expect(recorder.events.last?.name == .accountChanged)
        #expect(recorder.events.last?.reason == .accountChange)
        #expect(!(try recorder.freshShareReport()).contains("PRIVATE_"))
        monitor.stop(); monitor.stop()
        center.post(name: .CKAccountChanged, object: nil)
        #expect(recorder.events.count == 1)
        monitor.start()
        center.post(name: .CKAccountChanged, object: nil)
        #expect(recorder.events.count == 2)
    }

}
