import CloudKit
import Observation

/// Account availability only: SwiftData owns background data transfer.
enum CloudSyncAvailability: Equatable {
    case checking, available, noAccount, restricted, temporarilyUnavailable, unknown

    init(accountStatus: CKAccountStatus) {
        switch accountStatus {
        case .available: self = .available
        case .noAccount: self = .noAccount
        case .restricted: self = .restricted
        case .temporarilyUnavailable: self = .temporarilyUnavailable
        case .couldNotDetermine: self = .unknown
        @unknown default: self = .unknown
        }
    }

    var message: String {
        switch self {
        case .checking: "Checking iCloud availability…"
        case .available: "iCloud is available. Changes sync automatically when a connection is available; this does not confirm that every change has transferred."
        case .noAccount: "Sign in to your Apple Account in device Settings to use iCloud sync. You can keep editing offline."
        case .restricted: "iCloud access is restricted. Check device restrictions in Settings. You can keep editing offline."
        case .temporarilyUnavailable: "iCloud is temporarily unavailable. Try again later. You can keep editing offline."
        case .unknown: "Could not check iCloud availability. Check your connection and try again. You can keep editing offline."
        }
    }
}

@MainActor
@Observable
final class CloudSyncStatus {
    private(set) var availability: CloudSyncAvailability = .checking
    private(set) var isRefreshing = false
    private var needsAnotherRefresh = false
    private let accountStatus: () async throws -> CKAccountStatus

    init(accountStatus: @escaping () async throws -> CKAccountStatus = {
        try await CKContainer(identifier: AppPersistence.cloudKitContainerIdentifier).accountStatus()
    }) {
        self.accountStatus = accountStatus
    }

    func refresh() async {
        guard !isRefreshing else {
            needsAnotherRefresh = true
            return
        }
        isRefreshing = true
        defer { isRefreshing = false }
        repeat {
            needsAnotherRefresh = false
            do { availability = CloudSyncAvailability(accountStatus: try await accountStatus()) }
            catch { availability = .unknown }
        } while needsAnotherRefresh
    }
}
