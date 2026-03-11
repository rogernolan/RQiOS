import Foundation

enum TextImportFixtureLoader {
    static func text(named name: String) throws -> String {
        let bundle = Bundle(for: FixtureBundleToken.self)
        guard let fileURL = bundle.url(forResource: name, withExtension: "txt") else {
            throw CocoaError(.fileNoSuchFile)
        }

        return try String(contentsOf: fileURL, encoding: .utf8)
    }
}

private final class FixtureBundleToken {}
