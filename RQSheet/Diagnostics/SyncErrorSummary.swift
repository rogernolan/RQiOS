import CloudKit
import Foundation

/// Numeric diagnostics only. Never retain userInfo keys, descriptions or record identifiers.
nonisolated struct SyncErrorSummary: Codable, Equatable, Sendable {
    enum Domain: String, Codable, Sendable { case cloudKit, cocoa, posix, url, sqlite, other }
    struct Code: Codable, Equatable, Sendable {
        let domain: Domain
        let code: Int
        init(_ error: NSError) {
            switch error.domain {
            case CKErrorDomain: domain = .cloudKit
            case NSCocoaErrorDomain: domain = .cocoa
            case NSPOSIXErrorDomain: domain = .posix
            case NSURLErrorDomain: domain = .url
            case "NSSQLiteErrorDomain": domain = .sqlite
            default: domain = .other
            }
            code = error.code
        }
    }
    let domain: Domain
    let code: Int
    let retryAfter: Double?
    let underlying: [Code]
    let partial: [Code]

    init(_ error: any Error) {
        let error = error as NSError
        let safe = Code(error)
        domain = safe.domain
        code = safe.code
        let retry = (error.userInfo[CKErrorRetryAfterKey] as? NSNumber)?.doubleValue
        retryAfter = retry.flatMap { $0.isFinite && $0 >= 0 ? $0 : nil }
        var chain: [Code] = []
        var current = error
        for _ in 0..<4 {
            guard let next = current.userInfo[NSUnderlyingErrorKey] as? NSError else { break }
            chain.append(Code(next)); current = next
        }
        underlying = chain
        let values = (error.userInfo[CKPartialErrorsByItemIDKey] as? NSDictionary)?.allValues ?? []
        partial = values.compactMap { ($0 as? NSError).map(Code.init) }
            .sorted { ($0.domain.rawValue, $0.code) < ($1.domain.rawValue, $1.code) }.prefix(8).map { $0 }
    }
    var isValid: Bool {
        underlying.count <= 4 && partial.count <= 8 && (retryAfter.map { $0.isFinite && $0 >= 0 } ?? true)
    }
}
