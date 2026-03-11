import Foundation

struct DetectedTextImportSections: Equatable {
    private let sectionContents: [TextImportSection: String]
    let trailingNotes: String?

    init(sectionContents: [TextImportSection: String], trailingNotes: String?) {
        self.sectionContents = sectionContents
        self.trailingNotes = trailingNotes?.nilIfBlank
    }

    func content(for section: TextImportSection) -> String? {
        sectionContents[section]?.nilIfBlank
    }
}

enum TextImportSectionDetector {
    static func detect(in rawText: String) throws -> DetectedTextImportSections {
        let normalized = TextImportNormalizer.normalize(rawText)
        let lines = normalized.components(separatedBy: "\n")

        let attributesStart = firstIndex(in: lines) { isAttributesHeading($0) } ?? 0
        let runesStart = firstIndex(in: lines, startingAt: attributesStart + 1) { isRuneHeading($0) || isElementalRuneLine($0) } ?? attributesStart
        let passionsStart = firstIndex(in: lines, startingAt: runesStart + 1) { isPassionsHeading($0) }
        let combatStart = firstIndex(in: lines, startingAt: (passionsStart ?? runesStart) + 1) { isCombatSignature($0) || isWeaponHeader($0) }
        let skillsStart = firstIndex(in: lines, startingAt: (combatStart ?? (passionsStart ?? runesStart)) + 1) { isSkillGroupHeading($0) }
        let magicStart = firstIndex(in: lines, startingAt: (skillsStart ?? 0) + 1) { isMagicHeading($0) }
        let explicitEquipmentStart = firstIndex(in: lines, startingAt: (magicStart ?? 0) + 1) { isExplicitEquipmentHeading($0) }
        let backstoryStart = firstIndex(in: lines, startingAt: (magicStart ?? 0) + 1) { isBackstoryHeading($0) }

        let explicitEquipmentEnd = explicitEquipmentStart.flatMap { findEquipmentBlockEnd(in: lines, startingAt: $0) }
        let trailingStart = explicitEquipmentEnd.flatMap { nextNonEmptyLine(in: lines, after: $0) } ?? backstoryStart

        var sections: [TextImportSection: String] = [:]
        let endOfStructuredText = trailingStart ?? lines.endIndex

        assign(
            .characterInfo,
            from: 0,
            to: attributesStart,
            in: lines,
            into: &sections
        )

        assign(
            .attributes,
            from: attributesStart,
            to: runesStart,
            in: lines,
            into: &sections
        )

        assign(
            .runes,
            from: runesStart,
            to: passionsStart ?? combatStart ?? skillsStart ?? magicStart ?? endOfStructuredText,
            in: lines,
            into: &sections
        )

        if let passionsStart {
            assign(
                .passions,
                from: passionsStart,
                to: combatStart ?? skillsStart ?? magicStart ?? endOfStructuredText,
                in: lines,
                into: &sections
            )
        }

        if let combatStart, let skillsStart, combatStart < skillsStart {
            append(
                .equipment,
                from: combatStart,
                to: skillsStart,
                in: lines,
                into: &sections
            )
        }

        if let skillsStart {
            assign(
                .skills,
                from: skillsStart,
                to: magicStart ?? explicitEquipmentStart ?? endOfStructuredText,
                in: lines,
                into: &sections
            )
        }

        if let magicStart {
            assign(
                .magic,
                from: magicStart,
                to: explicitEquipmentStart ?? trailingStart ?? lines.endIndex,
                in: lines,
                into: &sections
            )
        }

        if let explicitEquipmentStart {
            append(
                .equipment,
                from: explicitEquipmentStart,
                to: explicitEquipmentEnd ?? trailingStart ?? lines.endIndex,
                in: lines,
                into: &sections
            )
        }

        let trailingNotes = trailingStart.map { join(lines[$0..<lines.endIndex]) }
        return DetectedTextImportSections(sectionContents: sections, trailingNotes: trailingNotes)
    }

    private static func assign(
        _ section: TextImportSection,
        from start: Int,
        to end: Int,
        in lines: [String],
        into sections: inout [TextImportSection: String]
    ) {
        guard start >= 0, end > start, start < lines.endIndex else { return }
        let boundedEnd = min(end, lines.endIndex)
        let content = join(lines[start..<boundedEnd])
        guard !content.isEmpty else { return }
        sections[section] = content
    }

    private static func append(
        _ section: TextImportSection,
        from start: Int,
        to end: Int,
        in lines: [String],
        into sections: inout [TextImportSection: String]
    ) {
        guard start >= 0, end > start, start < lines.endIndex else { return }
        let boundedEnd = min(end, lines.endIndex)
        let content = join(lines[start..<boundedEnd])
        guard !content.isEmpty else { return }
        if let existing = sections[section], !existing.isEmpty {
            sections[section] = existing + "\n\n" + content
        } else {
            sections[section] = content
        }
    }

    private static func join(_ slice: ArraySlice<String>) -> String {
        slice.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func firstIndex(
        in lines: [String],
        startingAt start: Int = 0,
        where predicate: (String) -> Bool
    ) -> Int? {
        guard start < lines.endIndex else { return nil }
        for index in max(0, start)..<lines.endIndex where predicate(lines[index]) {
            return index
        }
        return nil
    }

    private static func nextNonEmptyLine(in lines: [String], after index: Int) -> Int? {
        guard index < lines.endIndex else { return nil }
        for next in (index + 1)..<lines.endIndex where !lines[next].trimmingCharacters(in: .whitespaces).isEmpty {
            return next
        }
        return nil
    }

    private static func findEquipmentBlockEnd(in lines: [String], startingAt start: Int) -> Int? {
        guard start < lines.endIndex else { return nil }

        var sawContent = false
        for index in (start + 1)..<lines.endIndex {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                if sawContent {
                    return index
                }
                continue
            }

            sawContent = true

            if isBackstoryHeading(line) {
                return index
            }
        }

        return lines.endIndex
    }

    private static func isAttributesHeading(_ line: String) -> Bool {
        let canonical = TextImportNormalizer.canonicalFieldText(line).lowercased()
        return canonical == "characteristics"
    }

    private static func isRuneHeading(_ line: String) -> Bool {
        let canonical = TextImportNormalizer.canonicalFieldText(line).lowercased()
        return canonical == "elemental rune" ||
            canonical == "elemental runes" ||
            canonical == "power rune" ||
            canonical == "power rune affinities" ||
            canonical == "power rune affinity"
    }

    private static func isElementalRuneLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("Air:") ||
            trimmed.hasPrefix("Fire/Sky:") ||
            trimmed.hasPrefix("Darkness:") ||
            trimmed.hasPrefix("Water:") ||
            trimmed.hasPrefix("Earth:") ||
            trimmed.hasPrefix("Moon:")
    }

    private static func isPassionsHeading(_ line: String) -> Bool {
        TextImportNormalizer.canonicalFieldText(line).lowercased() == "passions"
    }

    private static func isCombatSignature(_ line: String) -> Bool {
        let canonical = TextImportNormalizer.canonicalFieldText(line).lowercased()
        return canonical.contains("hp total / currently") ||
            canonical.contains("healing rate:")
    }

    private static func isWeaponHeader(_ line: String) -> Bool {
        TextImportNormalizer.canonicalFieldText(line).lowercased().hasPrefix("weapon sr hit% damage")
    }

    private static func isSkillGroupHeading(_ line: String) -> Bool {
        let canonical = TextImportNormalizer.canonicalFieldText(line).lowercased()
        return canonical.hasPrefix("agility ") ||
            canonical == "agility" ||
            canonical.hasPrefix("communication ") ||
            canonical == "communication" ||
            canonical.hasPrefix("knowledge ") ||
            canonical == "knowledge" ||
            canonical.hasPrefix("magic ") ||
            canonical == "magic" ||
            canonical.hasPrefix("manipulation ") ||
            canonical == "manipulation" ||
            canonical.hasPrefix("perception ") ||
            canonical == "perception" ||
            canonical.hasPrefix("stealth ") ||
            canonical == "stealth"
    }

    private static func isMagicHeading(_ line: String) -> Bool {
        let canonical = TextImportNormalizer.canonicalFieldText(line).lowercased()
        return canonical == "rune magic" ||
            canonical == "spirit magic"
    }

    private static func isExplicitEquipmentHeading(_ line: String) -> Bool {
        TextImportNormalizer.canonicalFieldText(line).lowercased() == "equipment"
    }

    private static func isBackstoryHeading(_ line: String) -> Bool {
        TextImportNormalizer.canonicalFieldText(line).lowercased() == "backstory:"
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
