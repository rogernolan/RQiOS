import Foundation

enum TextImportNormalizer {
    static func normalize(_ rawText: String) -> String {
        let unifiedLineEndings = rawText
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        let withoutBadges = unifiedLineEndings.replacingOccurrences(
            of: #" ?Microbadge: Glorantha fan:\s*[^:\n]+? rune"#,
            with: "",
            options: .regularExpression
        )

        return withoutBadges
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in
                String(line)
                    .replacingOccurrences(of: "\t", with: " ")
                    .trimmingCharacters(in: .whitespaces)
            }
            .joined(separator: "\n")
    }

    static func canonicalFieldText(_ text: String) -> String {
        text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")
    }

    static func isPlaceholder(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return false }

        let normalized = trimmed.replacingOccurrences(of: " ", with: "")
        let uppercase = normalized.uppercased()

        let exactPlaceholders: Set<String> = [
            "_", "__", "___", "____", "_____", "##", "#", "--", "--%", "?", "?%", "__/__"
        ]

        if exactPlaceholders.contains(uppercase) {
            return true
        }

        return uppercase.allSatisfy { character in
            "_-#?%/".contains(character)
        }
    }
}
