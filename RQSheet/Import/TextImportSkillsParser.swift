import Foundation

enum TextImportSkillsParser {
    static func parse(_ sections: DetectedTextImportSections) -> TextImportResult {
        var result = TextImportResult()
        guard let skillsText = sections.content(for: .skills) else { return result }

        var currentGroup: SkillGroup?
        var supportedGroupsWithSkills = Set<SkillGroup>()
        var encounteredSupportedGroups = Set<SkillGroup>()
        var encounteredUnsupportedGroups = Set<String>()

        for line in skillsText.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            guard !trimmed.localizedCaseInsensitiveContains("all % are with category modifiers") else { continue }

            if let header = parseGroupHeader(from: trimmed) {
                switch header {
                case .supported(let group):
                    currentGroup = group
                    encounteredSupportedGroups.insert(group)
                case .unsupported(let title):
                    currentGroup = nil
                    encounteredUnsupportedGroups.insert(title)
                }
                continue
            }

            guard let currentGroup else { continue }
            guard let skill = parseSkillLine(trimmed, group: currentGroup) else { continue }

            result.skills.append(skill)
            supportedGroupsWithSkills.insert(currentGroup)
        }

        result.coverage.foundSkills = result.skills.count
        result.coverage.foundSkillGroups = supportedGroupsWithSkills.count
        result.coverage.expectedSkillGroups = encounteredSupportedGroups.count + encounteredUnsupportedGroups.count
        result.coverage.unsupportedSkillGroups = encounteredUnsupportedGroups.count
        return result
    }

    private static func parseSkillLine(_ line: String, group: SkillGroup) -> ParsedSkillEntry? {
        guard let (rawName, rawPercentage) = firstMatchGroups(in: line, pattern: #"^(.*?)([0-9]+)%"#),
              let percentage = Int(rawPercentage)
        else {
            return nil
        }

        let name = rawName
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty, !containsPlaceholder(in: name) else { return nil }

        return ParsedSkillEntry(
            name: name,
            groupName: group.rawValue,
            percentage: percentage,
            isCustom: !knownSkillNames[group, default: []].contains(normalizeSkillName(name))
        )
    }

    private static func containsPlaceholder(in name: String) -> Bool {
        let separatorSet = CharacterSet(charactersIn: " :()")
        return name
            .components(separatedBy: separatorSet)
            .contains(where: { token in
                let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmed.isEmpty && TextImportNormalizer.isPlaceholder(trimmed)
            })
    }

    private static func parseGroupHeader(from line: String) -> ParsedGroupHeader? {
        let canonical = TextImportNormalizer.canonicalFieldText(line)
        guard canonical.range(of: #"[+-][0-9]+%$"#, options: .regularExpression) != nil else {
            return nil
        }

        let title = canonical.replacingOccurrences(of: #"\s*[+-][0-9]+%$"#, with: "", options: .regularExpression)
        switch title.lowercased() {
        case "agility":
            return .supported(.agility)
        case "communication":
            return .supported(.communication)
        case "knowledge":
            return .supported(.knowledge)
        case "magic":
            return .supported(.magic)
        case "manipulation":
            return .supported(.manipulation)
        case "perception":
            return .supported(.perception)
        case "stealth":
            return .supported(.stealth)
        default:
            return .unsupported(title)
        }
    }

    private static func normalizeSkillName(_ name: String) -> String {
        name
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
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

    private static let knownSkillNames: [SkillGroup: Set<String>] = [
        .agility: [
            "boat",
            "climb",
            "dodge",
            "drive chariot",
            "jump",
            "ride (mount type)",
            "swim",
        ],
        .communication: [
            "act",
            "art",
            "bargain",
            "charm",
            "dance",
            "disguise",
            "fast talk",
            "intimidate",
            "intrigue",
            "orate",
            "sing",
            "speak own language",
            "speak other language",
        ],
        .knowledge: [
            "alchemy",
            "animal lore",
            "battle",
            "bureaucracy",
            "celestial lore",
            "cult lore (specific cult)",
            "customs",
            "elder race lore (race)",
            "evaluate",
            "farm",
            "first aid",
            "game",
            "herd",
            "homeland lore (local)",
            "homeland lore (other)",
            "library use",
            "manage household",
            "mineral lore",
            "peaceful cut",
            "plant lore",
            "read/write (language)",
            "shiphandling",
            "survival",
            "treat disease",
            "treat poison",
        ],
        .magic: [
            "meditate",
            "prepare corpse",
            "sense assassin",
            "sense chaos",
            "spirit combat",
            "spirit dance",
            "spirit lore",
            "spirit travel",
            "understand herd beast",
            "worship (deity)",
        ],
        .manipulation: [
            "conceal",
            "craft (specific craft)",
            "devise",
            "melee weapon",
            "missile weapon",
            "play instrument",
            "shield",
            "sleight",
        ],
        .perception: [
            "insight",
            "listen",
            "scan",
            "search",
            "track",
        ],
        .stealth: [
            "hide",
            "move quietly",
        ],
    ]
}

private enum ParsedGroupHeader {
    case supported(SkillGroup)
    case unsupported(String)
}
