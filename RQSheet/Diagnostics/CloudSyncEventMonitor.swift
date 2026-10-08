import CloudKit
import CoreData
import Foundation

/// Owns Apple's public event observer independently of Settings and persistence retries.
nonisolated final class CloudSyncEventMonitor: @unchecked Sendable {
    private let center: NotificationCenter
    private let diagnostics: SyncDiagnostics
    private let lock = NSLock()
    private var observer: NSObjectProtocol?
    private var accountObserver: NSObjectProtocol?
    init(center: NotificationCenter = .default, diagnostics: SyncDiagnostics = .shared) {
        self.center = center; self.diagnostics = diagnostics
    }
    var isRunning: Bool { lock.lock(); defer { lock.unlock() }; return observer != nil }
    func start() {
        lock.lock(); defer { lock.unlock() }
        guard observer == nil else { return }
        observer = center.addObserver(forName: NSPersistentCloudKitContainer.eventChangedNotification, object: nil, queue: nil) { [weak self] notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else { return }
            self?.record(type: event.type, start: event.startDate, end: event.endDate, succeeded: event.succeeded, error: event.error)
        }
        accountObserver = center.addObserver(forName: .CKAccountChanged, object: nil, queue: nil) { [weak self] _ in
            self?.diagnostics.record(.accountChanged, stage: .started, reason: .accountChange)
        }
    }
    func stop() {
        lock.lock(); defer { lock.unlock() }
        if let observer { center.removeObserver(observer); self.observer = nil }
        if let accountObserver { center.removeObserver(accountObserver); self.accountObserver = nil }
    }
    deinit {
        if let observer { center.removeObserver(observer) }
        if let accountObserver { center.removeObserver(accountObserver) }
    }
    func record(type: NSPersistentCloudKitContainer.EventType, start: Date, end: Date?, succeeded: Bool, error: (any Error)?) {
        let name: SyncDiagnostics.Name
        switch type {
        case .setup: name = .cloudSetup
        case .import: name = .cloudImport
        case .export: name = .cloudExport
        @unknown default: return
        }
        diagnostics.record(name, stage: end == nil ? .started : .completed,
            success: end == nil ? nil : succeeded, duration: end.map { $0.timeIntervalSince(start) }, error: error)
    }
}
