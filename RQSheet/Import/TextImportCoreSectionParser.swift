import Foundation

enum TextImportCoreSectionParser {
    static func parse(_ sections: DetectedTextImportSections) -> TextImportResult {
        var result = TextImportResult()

        if let characterInfoText = sections.content(for: .characterInfo) {
            result.characterInfo = parseCharacterInfo(from: characterInfoText)
            result.coverage.expectedIdentityFields = expectedIdentityFieldCount(in: characterInfoText)
            result.coverage.foundIdentityFields = foundIdentityFieldCount(in: result.characterInfo)
        }

        if let attributesText = sections.content(for: .attributes) {
            result.attributes = parseAttributes(from: attributesText)
        }
        result.coverage.expectedAttributes = 7
        result.coverage.foundAttributes = result.attributes.count

        if let runesText = sections.content(for: .runes) {
            result.runePercentages = parseRunes(from: runesText)
        }
        result.coverage.expectedRunes = 16
        result.coverage.foundRunes = result.runePercentages.count

        if let passionsText = sections.content(for: .passions) {
            result.characterInfo.honor = parseHonor(from: passionsText)
            result.passions = parsePassions(from: passionsText)
        }
        result.coverage.foundPassions = result.passions.count

        return result
    }

    private static func parseCharacterInfo(from section: String) -> ParsedCharacterInfo {
        let flattened = TextImportNormalizer.canonicalFieldText(section)
        let lines = section.components(separatedBy: "\n")

        let candidateName = cleanedValue(
            extractField(
                in: flattened,
                labelPattern: "Name:",
                stopPatterns: fieldStopPatterns
            )
        ) ?? fallbackName(in: lines)

        let family = cleanedValue(
            extractField(
                in: flattened,
                labelPattern: "Family:|Nochet House:|(?<!Patron )House:",
                stopPatterns: fieldStopPatterns
            )
        )

        let patron = cleanedValue(
            extractField(
                in: flattened,
                labelPattern: "Patron House:",
                stopPatterns: fieldStopPatterns
            )
        )

        let originalHouse = cleanedValue(
            extractField(
                in: flattened,
                labelPattern: "Original House\\s*:?",
                stopPatterns: fieldStopPatterns
            )
        )

        let dateOfBirth = cleanedValue(
            extractField(
                in: flattened,
                labelPattern: "Born:",
                stopPatterns: fieldStopPatterns
            )
        )

        let occupation = cleanedValue(
            extractField(
                in: flattened,
                labelPattern: "Occupation:",
                stopPatterns: fieldStopPatterns
            )
        )

        let reputation = extractPercentage(
            extractField(
                in: flattened,
                labelPattern: "Reputation:",
                stopPatterns: fieldStopPatterns
            )
        )

        let sol = cleanedValue(
            extractField(
                in: flattened,
                labelPattern: "SoL:",
                stopPatterns: fieldStopPatterns
            )
        )

        let income = cleanedValue(
            extractField(
                in: flattened,
                labelPattern: "Income:",
                stopPatterns: fieldStopPatterns
            )
        )

        let ransom = extractInt(
            extractField(
                in: flattened,
                labelPattern: "Ransom:",
                stopPatterns: fieldStopPatterns
            )
        )

        let cults = parseCults(from: lines)

        return ParsedCharacterInfo(
            candidateName: candidateName,
            family: family,
            patron: patron,
            originalHouse: originalHouse,
            dateOfBirth: dateOfBirth,
            occupation: occupation,
            reputation: reputation,
            sol: sol,
            income: income,
            ransom: ransom,
            cult: cults.first,
            worships: Array(cults.dropFirst())
        )
    }

    private static func parseAttributes(from section: String) -> [RQCharacter.Characteristic: Int] {
        let flattened = TextImportNormalizer.canonicalFieldText(section)
        let pairs: [(RQCharacter.Characteristic, String)] = [
            (.str, "STR"),
            (.con, "CON"),
            (.siz, "SIZ"),
            (.dex, "DEX"),
            (.int, "INT"),
            (.pow, "POW"),
            (.cha, "CHA"),
        ]

        return Dictionary(uniqueKeysWithValues: pairs.compactMap { characteristic, key in
            guard let value = extractInt(match(in: flattened, pattern: #"\b\#(key):\s*([0-9]+)"#)) else {
                return nil
            }
            return (characteristic, value)
        })
    }

    private static func parseRunes(from section: String) -> [RuneName: Int] {
        var runePercentages: [RuneName: Int] = [:]

        for line in section.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || isRuneHeadingLine(trimmed) || trimmed.contains("must total 100%") {
                continue
            }

            if let (nameText, valueText) = firstMatchGroups(in: trimmed, pattern: #"^([A-Za-z/]+):\s*([~]?[0-9]+)"#),
               let runeName = runeName(from: nameText),
               let value = extractInt(valueText)
            {
                runePercentages[runeName] = value
                continue
            }

            if let (leftValue, leftName, rightName, rightValue) = firstMatchGroups(
                in: trimmed,
                pattern: #".*?([0-9]+)\s+([A-Za-z/*]+)\s*\|\s*([A-Za-z/*]+)\s+([0-9]+)"#
            ),
               let leftRune = runeName(from: leftName),
               let rightRune = runeName(from: rightName),
               let left = extractInt(leftValue),
               let right = extractInt(rightValue)
            {
                runePercentages[leftRune] = left
                runePercentages[rightRune] = right
            }
        }

        return runePercentages
    }

    private static func parsePassions(from section: String) -> [ParsedPassionEntry] {
        section
            .components(separatedBy: "\n")
            .compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty, trimmed.compare("Passions", options: .caseInsensitive) != .orderedSame else {
                    return nil
                }
                guard let (nameText, percentageText) = firstMatchGroups(in: trimmed, pattern: #"^(.*?)([0-9]+)%"#),
                      let percentage = Int(percentageText)
                else {
                    return nil
                }

                let cleanedName = nameText
                    .replacingOccurrences(of: ":", with: "")
                    .replacingOccurrences(of: "?", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                guard !cleanedName.isEmpty else { return nil }
                guard cleanedName.compare("Honor", options: .caseInsensitive) != .orderedSame else {
                    return nil
                }
                return ParsedPassionEntry(name: cleanedName, percentage: percentage)
            }
    }

    private static func parseHonor(from section: String) -> Int? {
        for line in section.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.isEmpty == false else { continue }
            guard let (nameText, percentageText) = firstMatchGroups(in: trimmed, pattern: #"^(.*?)([0-9]+)%"#),
                  let percentage = Int(percentageText)
            else {
                continue
            }

            let cleanedName = nameText
                .replacingOccurrences(of: ":", with: "")
                .replacingOccurrences(of: "?", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if cleanedName.compare("Honor", options: .caseInsensitive) == .orderedSame {
                return percentage
            }
        }

        return nil
    }

    private static func parseCults(from lines: [String]) -> [String] {
        lines.compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.localizedCaseInsensitiveContains("initiate of") || trimmed.hasPrefix("Cult:") else {
                return nil
            }

            let rawCult = trimmed
                .replacingOccurrences(of: "Cult:", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "Initiate of", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let value = cleanedValue(rawCult) else { return nil }
            return value
        }
    }

    private static func expectedIdentityFieldCount(in section: String) -> Int {
        let flattened = TextImportNormalizer.canonicalFieldText(section)
        var count = 0
        if extractField(in: flattened, labelPattern: "Name:", stopPatterns: fieldStopPatterns) != nil || fallbackName(in: section.components(separatedBy: "\n")) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "Family:|Nochet House:|(?<!Patron )House:", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "Patron House:", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "Original House\\s*:?", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "Born:", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "Occupation:", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "Reputation:", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "SoL:", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "Income:", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if extractField(in: flattened, labelPattern: "Ransom:", stopPatterns: fieldStopPatterns) != nil { count += 1 }
        if !parseCults(from: section.components(separatedBy: "\n")).isEmpty { count += 1 }
        return count
    }

    private static func foundIdentityFieldCount(in info: ParsedCharacterInfo) -> Int {
        [
            info.candidateName,
            info.family,
            info.patron,
            info.originalHouse,
            info.dateOfBirth,
            info.occupation,
            info.sol,
            info.income,
            info.cult,
        ].compactMap { $0 }.count + (info.reputation != nil ? 1 : 0) + (info.ransom != nil ? 1 : 0)
    }

    private static func fallbackName(in lines: [String]) -> String? {
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            guard !trimmed.contains(":") else { continue }
            guard !isAttributesHeadingLine(trimmed), !isRuneHeadingLine(trimmed), !trimmed.localizedCaseInsensitiveContains("passions") else {
                continue
            }
            return trimmed
        }
        return nil
    }

    private static func extractField(in text: String, labelPattern: String, stopPatterns: [String]) -> String? {
        let stops = stopPatterns.joined(separator: "|")
        let pattern = "(?i)(?:\(labelPattern))\\s*(.*?)\\s*(?=(?:\(stops))|$)"
        return match(in: text, pattern: pattern)
    }

    private static func cleanedValue(_ text: String?) -> String? {
        guard let text else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !TextImportNormalizer.isPlaceholder(trimmed) else { return nil }
        return trimmed
    }

    private static func extractPercentage(_ text: String?) -> Int? {
        extractInt(text)
    }

    private static func extractInt(_ text: String?) -> Int? {
        guard let text else { return nil }
        let digits = text.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        return Int(digits)
    }

    private static func match(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 1,
              let captureRange = Range(match.range(at: 1), in: text)
        else {
            return nil
        }
        return String(text[captureRange])
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

    private static func firstMatchGroups(in text: String, pattern: String) -> (String, String, String, String)? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 4,
              let first = Range(match.range(at: 1), in: text),
              let second = Range(match.range(at: 2), in: text),
              let third = Range(match.range(at: 3), in: text),
              let fourth = Range(match.range(at: 4), in: text)
        else {
            return nil
        }
        return (String(text[first]), String(text[second]), String(text[third]), String(text[fourth]))
    }

    private static func runeName(from text: String) -> RuneName? {
        let cleaned = text
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()

        switch cleaned {
        case "air": return .air
        case "fire/sky": return .fire
        case "darkness": return .darkness
        case "water": return .water
        case "earth": return .earth
        case "moon": return .moon
        case "man": return .man
        case "beast": return .beast
        case "fertility": return .fertility
        case "death": return .death
        case "harmony": return .harmony
        case "disorder": return .disorder
        case "truth": return .truth
        case "illusion": return .illusion
        case "stasis": return .stasis
        case "movement": return .movement
        default:
            return nil
        }
    }

    private static func isAttributesHeadingLine(_ line: String) -> Bool {
        TextImportNormalizer.canonicalFieldText(line).lowercased() == "characteristics"
    }

    private static func isRuneHeadingLine(_ line: String) -> Bool {
        let canonical = TextImportNormalizer.canonicalFieldText(line).lowercased()
        return canonical == "elemental rune" ||
            canonical == "elemental runes" ||
            canonical == "power rune" ||
            canonical == "power rune affinities"
    }

    private static let fieldStopPatterns = [
        "Name:",
        "Family:",
        "Nochet House:",
        "(?<!Patron )House:",
        "Patron House:",
        "Original House\\s*:?",
        "Born:",
        "Reputation:",
        "Occupation:",
        "SoL:",
        "Income:",
        "Ransom:",
        "NOW\\s*:",
        "MOV:",
        "Cult:",
        "Initiate of",
    ]
}
