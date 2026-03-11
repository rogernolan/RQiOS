import Foundation

enum TextImportEquipmentAndMagicParser {
    static func parse(_ sections: DetectedTextImportSections) -> TextImportResult {
        var result = TextImportResult()

        if let equipmentText = sections.content(for: .equipment) {
            let parsed = parseEquipmentSection(equipmentText)
            result.weapons = parsed.weapons
            result.equipment = parsed.items
        }
        result.coverage.foundEquipmentEntries = result.weapons.count + result.equipment.count

        if let magicText = sections.content(for: .magic) {
            result.magic = parseMagicSection(magicText)
        }
        result.coverage.foundMagicEntries = result.magic.count
        result.trailingNotes = sections.trailingNotes

        return result
    }

    private static func parseEquipmentSection(_ section: String) -> (items: [String], weapons: [ParsedWeaponEntry]) {
        var items: [String] = []
        var weapons: [ParsedWeaponEntry] = []
        var inWeaponTable = false

        for line in section.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                continue
            }

            if isWeaponHeader(trimmed) {
                inWeaponTable = true
                continue
            }

            if trimmed.compare("Equipment", options: .caseInsensitive) == .orderedSame {
                inWeaponTable = false
                continue
            }

            if let weapon = parseWeaponLine(trimmed) {
                inWeaponTable = true
                weapons.append(weapon)
                continue
            }

            if isCombatNoise(trimmed) {
                continue
            }

            if inWeaponTable == false || trimmed.localizedCaseInsensitiveContains("armour points show") {
                items.append(trimmed)
            }
        }

        return (items, weapons)
    }

    private static func parseMagicSection(_ section: String) -> [ParsedSpellEntry] {
        var spells: [ParsedSpellEntry] = []
        var currentSource = "Magic"

        for line in section.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if let heading = spellHeading(from: trimmed) {
                currentSource = heading
                continue
            }

            for match in regexMatches(in: trimmed, pattern: #"([A-Za-z0-9'’/ +:-]+?)\s*\((\d+)\)"#) {
                guard let points = Int(match.1) else { continue }
                let name = match.0.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { continue }
                spells.append(ParsedSpellEntry(name: name, points: points, source: currentSource))
            }

            if currentSource.localizedCaseInsensitiveContains("spells"),
               trimmed.contains(":") == false,
               let bareMatch = firstMatchGroups(in: trimmed, pattern: #"^(.*?)(\d+)$"#),
               trimmed.contains("(") == false
            {
                let name = bareMatch.0.trimmingCharacters(in: .whitespacesAndNewlines)
                if let points = Int(bareMatch.1), name.isEmpty == false {
                    spells.append(ParsedSpellEntry(name: name, points: points, source: currentSource))
                }
            }
        }

        return spells
    }

    private static func parseWeaponLine(_ line: String) -> ParsedWeaponEntry? {
        guard line.contains("%") else { return nil }
        let tokens = line.split(whereSeparator: \.isWhitespace).map(String.init)
        guard let percentIndex = tokens.firstIndex(where: { $0.contains("%") }),
              percentIndex > 0,
              let percentage = Int(tokens[percentIndex].filter(\.isNumber))
        else {
            return nil
        }

        let srIndex = percentIndex - 1
        let hasStrikeRank = isStrikeRankToken(tokens[srIndex])
        let nameTokens = hasStrikeRank ? Array(tokens[..<srIndex]) : Array(tokens[..<percentIndex])
        let name = nameTokens.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }

        let meaningfulTail = tokens[(percentIndex + 1)...].filter { $0 != "[" && $0 != "]" }
        let damage = meaningfulTail.first(where: isDamageToken)
        let damageIndex = meaningfulTail.firstIndex(where: isDamageToken)
        let range = damageIndex.flatMap { index -> String? in
            guard meaningfulTail.indices.contains(index + 1) else { return nil }
            let candidate = meaningfulTail[index + 1]
            return candidate.allSatisfy(\.isNumber) ? candidate : nil
        }

        return ParsedWeaponEntry(
            name: name,
            percentage: percentage,
            damage: damage,
            strikeRank: hasStrikeRank ? tokens[srIndex] : nil,
            range: range
        )
    }

    private static func spellHeading(from line: String) -> String? {
        if line.compare("Rune Magic", options: .caseInsensitive) == .orderedSame {
            return "Rune Magic"
        }
        if line.compare("Spirit Magic", options: .caseInsensitive) == .orderedSame {
            return "Spirit Magic"
        }
        if line.localizedCaseInsensitiveContains("Spells") {
            return line
        }
        return nil
    }

    private static func regexMatches(in text: String, pattern: String) -> [(String, String)] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            guard match.numberOfRanges > 2,
                  let first = Range(match.range(at: 1), in: text),
                  let second = Range(match.range(at: 2), in: text)
            else {
                return nil
            }
            return (String(text[first]), String(text[second]))
        }
    }

    private static func firstMatchGroups(in text: String, pattern: String) -> (String, String)? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 2,
              let first = Range(match.range(at: 1), in: text),
              let second = Range(match.range(at: 2), in: text)
        else {
            return nil
        }
        return (String(text[first]), String(text[second]))
    }

    private static func isWeaponHeader(_ line: String) -> Bool {
        let canonical = TextImportNormalizer.canonicalFieldText(line).lowercased()
        return canonical.hasPrefix("weapon sr hit% damage")
    }

    private static func isCombatNoise(_ line: String) -> Bool {
        let canonical = TextImportNormalizer.canonicalFieldText(line).lowercased()
        return canonical.contains("hp total / currently") ||
            canonical.hasPrefix("healing rate:") ||
            canonical.hasPrefix("dex sr:") ||
            canonical.hasPrefix("sr12") ||
            canonical.hasPrefix("magic bonus") ||
            canonical.hasPrefix("attack ") ||
            canonical.hasPrefix("damage:") ||
            canonical.hasPrefix("sorcery") ||
            canonical.hasPrefix("free int:") ||
            canonical.range(of: #"^[0-9]{1,2}(?:-[0-9]{1,2})?:\s"#, options: .regularExpression) != nil
    }

    private static func isStrikeRankToken(_ token: String) -> Bool {
        token.range(of: #"^[0-9SMR/\.]+$"#, options: .regularExpression) != nil
    }

    private static func isDamageToken(_ token: String) -> Bool {
        token.range(of: #"^(?:[0-9]+d[0-9]+(?:[+-][0-9]+)?|[0-9]+|special|\*)$"#, options: [.regularExpression, .caseInsensitive]) != nil
    }
}
