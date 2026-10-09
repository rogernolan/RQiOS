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
    private var pendingReason: SyncDiagnostics.Reason?
    private let diagnostics: SyncDiagnostics
    private let accountStatus: () async throws -> CKAccountStatus

    init(diagnostics: SyncDiagnostics = .shared, accountStatus: @escaping () async throws -> CKAccountStatus = {
        try await CKContainer(identifier: AppPersistence.cloudKitContainerIdentifier).accountStatus()
    }) {
        self.accountStatus = accountStatus
        self.diagnostics = diagnostics
    }

    func refresh(reason: SyncDiagnostics.Reason = .manual) async {
        guard !isRefreshing else {
            pendingReason = reason
            return
        }
        isRefreshing = true
        defer { isRefreshing = false }
        var currentReason = reason
        repeat {
            pendingReason = nil
            let start = Date()
            diagnostics.record(.accountCheck, stage: .started, reason: currentReason)
            do {
                availability = CloudSyncAvailability(accountStatus: try await accountStatus())
                diagnostics.record(.accountCheck, stage: .completed, success: true, duration: Date().timeIntervalSince(start), reason: currentReason, account: diagnosticAccount)
            } catch {
                availability = .unknown
                diagnostics.record(.accountCheck, stage: .completed, success: false, duration: Date().timeIntervalSince(start), reason: currentReason, account: .unknown, error: error)
            }
            if let pendingReason { currentReason = pendingReason }
        } while pendingReason != nil
    }

    private var diagnosticAccount: SyncDiagnostics.Account {
        switch availability {
        case .available: .available
        case .noAccount: .noAccount
        case .restricted: .restricted
        case .temporarilyUnavailable: .temporarilyUnavailable
        case .checking, .unknown: .unknown
        }
    }
}
