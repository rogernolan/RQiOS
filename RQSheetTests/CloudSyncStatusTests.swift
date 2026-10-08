import CloudKit
import Testing
@testable import RQSheet

@MainActor
struct CloudSyncStatusTests {
    @Test func mapsAccountAvailabilityWithoutClaimingTransferCompletion() {
        #expect(CloudSyncAvailability(accountStatus: .available) == .available)
        #expect(CloudSyncAvailability(accountStatus: .noAccount) == .noAccount)
        #expect(CloudSyncAvailability(accountStatus: .restricted) == .restricted)
        #expect(CloudSyncAvailability(accountStatus: .couldNotDetermine) == .unknown)
        #expect(CloudSyncAvailability(accountStatus: .temporarilyUnavailable) == .temporarilyUnavailable)
        #expect(CloudSyncAvailability.available.message == "iCloud is available. Changes sync automatically when a connection is available; this does not confirm that every change has transferred.")
        #expect(CloudSyncAvailability.noAccount.message.contains("Sign in"))
        #expect(CloudSyncAvailability.restricted.message.contains("restrictions"))
        #expect(CloudSyncAvailability.temporarilyUnavailable.message.contains("Try again"))
    }

    @Test func refreshUpdatesAccountStatusAndRecoversAfterAnError() async {
        var fails = true
        let status = CloudSyncStatus(diagnostics: .none) {
            if fails { throw CKError(.networkUnavailable) }
            return .available
        }
        #expect(status.availability == .checking)
        await status.refresh()
        #expect(status.availability == .unknown)
        #expect(status.availability.message.contains("connection"))
        fails = false
        await status.refresh()
        #expect(status.availability == .available)
    }
    @Test func refreshDuringAnAccountCheckRechecksInsteadOfLosingTheChange() async {
        var checks = 0
        var pending: CheckedContinuation<CKAccountStatus, Never>?
        let status = CloudSyncStatus(diagnostics: .none) {
            checks += 1
            if checks == 1 {
                return await withCheckedContinuation { pending = $0 }
            }
            return .available
        }
        let firstRefresh = Task { await status.refresh() }
        while pending == nil { await Task.yield() }
        await status.refresh()
        pending?.resume(returning: .noAccount)
        await firstRefresh.value
        #expect(checks == 2)
        #expect(status.availability == .available)
        #expect(status.isRefreshing == false)
    }

}
