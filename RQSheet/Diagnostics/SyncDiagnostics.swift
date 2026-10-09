import Foundation
import OSLog

/// A separate, bounded local history. Diagnostic I/O never throws into persistence startup.
nonisolated final class SyncDiagnostics: @unchecked Sendable {
    enum Name: String, Codable, Sendable {
        case startup, recoveryCopy, schemaRecognition, localMigration, graphVerification, containerOpening
        case cloudSetup, cloudImport, cloudExport, accountCheck, accountChanged, reportPreparation
    }
    enum Stage: String, Codable, Sendable { case started, completed, skipped }
    enum Reason: String, Codable, Sendable { case appearance, manual, foreground, accountChange, coalesced }
    enum Account: String, Codable, Sendable { case available, noAccount, restricted, temporarilyUnavailable, unknown }
    struct Event: Codable, Equatable, Sendable {
        let id: UUID
        let session: UUID
        let timestamp: Date
        let name: Name
        let stage: Stage
        let success: Bool?
        let duration: Double?
        let schemaVersion: Int?
        let reason: Reason?
        let account: Account?
        let error: SyncErrorSummary?
        var isValid: Bool {
            timestamp.timeIntervalSince1970.isFinite && (duration.map { $0.isFinite && $0 >= 0 } ?? true)
                && (schemaVersion.map { (1...2).contains($0) } ?? true) && (error?.isValid ?? true)
        }
    }
    static let subsystem = "com.diffeng.RQSheet"
    static let containerIdentifier = "iCloud.com.diffeng.RQSheet"
    static let shared = SyncDiagnostics(directory: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("SyncDiagnostics", isDirectory: true))
    static let none = SyncDiagnostics(directory: nil)
    let session: UUID
    let historyURL: URL
    private let directory: URL?
    private let eventLimit: Int
    private let byteLimit: Int
    private let clock: @Sendable () -> Date
    private let queue = DispatchQueue(label: "com.diffeng.RQSheet.diagnostics")
    private var history: [Event] = []
    private let failureLogger = Logger(subsystem: subsystem, category: "diagnostics")
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]; return encoder
    }()

    init(directory: URL?, eventLimit: Int = 200, byteLimit: Int = 256 * 1024,
         clock: @escaping @Sendable () -> Date = { Date() }, session: UUID = UUID()) {
        self.directory = directory
        historyURL = (directory ?? FileManager.default.temporaryDirectory).appendingPathComponent("history.json")
        self.eventLimit = max(0, min(eventLimit, 200)); self.byteLimit = max(2, min(byteLimit, 256 * 1024))
        self.clock = clock; self.session = session
        guard directory != nil, FileManager.default.fileExists(atPath: historyURL.path) else { return }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: historyURL.path)
            guard (attributes[.size] as? NSNumber)?.intValue ?? Int.max <= 256 * 1024 else { throw HistoryError.invalid }
            let data = try Data(contentsOf: historyURL)
            let decoded = try JSONDecoder().decode([Event].self, from: data)
            // Reject unknown keys before Codable can silently discard them.
            guard Self.hasAllowedKeys(data), decoded.allSatisfy(\.isValid) else { throw HistoryError.invalid }
            history = decoded
            trim()
        } catch { failureLogger.error("Diagnostic history could not be loaded; starting a clean history.") }
    }
    private static func hasAllowedKeys(_ data: Data) -> Bool {
        guard let events = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return false }
        let eventKeys: Set<String> = ["id", "session", "timestamp", "name", "stage", "success", "duration", "schemaVersion", "reason", "account", "error"]
        let errorKeys: Set<String> = ["domain", "code", "retryAfter", "underlying", "partial"]
        return events.allSatisfy { event in
            guard Set(event.keys).isSubset(of: eventKeys) else { return false }
            guard let error = event["error"] as? [String: Any] else { return event["error"] == nil }
            guard Set(error.keys).isSubset(of: errorKeys) else { return false }
            return ["underlying", "partial"].allSatisfy { key in
                guard let codes = error[key] as? [[String: Any]] else { return false }
                return codes.allSatisfy { Set($0.keys) == ["domain", "code"] }
            }
        }
    }
    var events: [Event] { queue.sync { history } }

    func record(_ name: Name, stage: Stage, success: Bool? = nil, duration: Double? = nil,
                schemaVersion: Int? = nil, reason: Reason? = nil, account: Account? = nil, error: (any Error)? = nil) {
        guard directory != nil else { return }
        queue.sync {
            let event = Event(id: UUID(), session: session, timestamp: clock(), name: name, stage: stage,
                success: success, duration: duration.flatMap { $0.isFinite && $0 >= 0 ? $0 : nil },
                schemaVersion: schemaVersion.flatMap { (1...2).contains($0) ? $0 : nil },
                reason: reason, account: account, error: error.map(SyncErrorSummary.init))
            guard event.isValid else { return }
            history.append(event); trim()
            let category: String
            switch name {
            case .cloudSetup, .cloudImport, .cloudExport, .accountCheck, .accountChanged: category = "cloud"
            case .reportPreparation: category = "diagnostics"
            default: category = "persistence"
            }
            // The encoded event contains only the fixed schema above.
            if let data = try? Self.encoder.encode(event), let value = String(data: data, encoding: .utf8) {
                Logger(subsystem: Self.subsystem, category: category).info("\(value, privacy: .public)")
            }
            do {
                try FileManager.default.createDirectory(at: directory!, withIntermediateDirectories: true)
                try Self.encoder.encode(history).write(to: historyURL, options: .atomic)
            } catch { failureLogger.error("Diagnostic history could not be saved; current events remain in memory.") }
        }
    }
    private func trim() {
        while history.count > eventLimit { history.removeFirst() }
        while !history.isEmpty && ((try? Self.encoder.encode(history).count) ?? Int.max) > byteLimit { history.removeFirst() }
    }
    func freshShareReport() throws -> String {
        try queue.sync {
            let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]; encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(history)
            guard let events = String(data: data, encoding: .utf8) else { throw HistoryError.invalid }
            #if DEBUG
            let configuration = "Debug"
            #else
            let configuration = "Release"
            #endif
            return """
            RQSheet Sync Diagnostics
            Version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown")
            Build: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown")
            Configuration: \(configuration)
            OS: \(ProcessInfo.processInfo.operatingSystemVersionString)
            Container: \(Self.containerIdentifier)
            Session: \(session.uuidString)
            Generated: \(ISO8601DateFormatter().string(from: clock()))
            Account availability and successful events do not prove every record has converged.
            Runtime CloudKit environment has not been observed.

            \(events)
            """
        }
    }
    private enum HistoryError: Error { case invalid }
}
