import Foundation
import SwiftData
import Testing
@testable import RQSheet

/// Deliberate opt-in integration probe. Ordinary unit tests never enable CloudKit.
@MainActor
struct CloudKitStoreInitializationTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["RQSHEET_VERIFY_CLOUDKIT"] == "1"))
    func initializesAnIsolatedOnDiskCloudKitStore() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: "rq-cloud-probe-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "probe.store")
        let container = try AppPersistence.makeContainer(storeURL: url, cloudKitEnabled: true)
        #expect(container.configurations.first?.cloudKitContainerIdentifier == AppPersistence.cloudKitContainerIdentifier)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<RQCharacter>()) == 0)
        #expect(FileManager.default.fileExists(atPath: url.path))
    }
}
