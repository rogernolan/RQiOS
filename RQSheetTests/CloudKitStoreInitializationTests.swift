import Foundation
import SwiftData
import Testing
@testable import RQSheet

/// Deliberate opt-in integration probe. Ordinary unit tests never enable CloudKit.
@MainActor
struct CloudKitStoreInitializationTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["RQSHEET_VERIFY_CLOUDKIT"] == "1"))
    func initializesAnIsolatedOnDiskCloudKitStore() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: "rq-cloud-probe-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "probe.store")
        let diagnostics = SyncDiagnostics(directory: directory.appending(path: "diagnostics"))
        let monitor = CloudSyncEventMonitor(diagnostics: diagnostics)
        monitor.start()
        defer { monitor.stop() }
        let container = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: true, diagnostics: diagnostics)
        #expect(container.configurations.first?.cloudKitContainerIdentifier == AppPersistence.cloudKitContainerIdentifier)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<RQCharacter>()) == 0)
        #expect(FileManager.default.fileExists(atPath: url.path))
        #expect(diagnostics.events.last?.name == .startup && diagnostics.events.last?.success == true)
        try await Task.sleep(for: .seconds(1))
        let cloudEvents = diagnostics.events.filter { [.cloudSetup, .cloudImport, .cloudExport].contains($0.name) }
        print("CloudKit probe observed \(cloudEvents.count) public events: \(cloudEvents.map { $0.name.rawValue + ":" + $0.stage.rawValue }.joined(separator: ", "))")
        #expect(monitor.isRunning)
    }
}
