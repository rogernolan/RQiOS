import Foundation

enum DropRule: Equatable {
    case lowest(Int)
    case highest(Int)
}

struct DiceExpression: Equatable {
    enum ParseError: Error {
        case invalidFormat
        case invalidDiceCount
        case invalidSides
        case invalidModifier
    }

    let diceCount: Int
    let sides: Int
    let dropRule: DropRule?
    let modifier: Int

    init(diceCount: Int, sides: Int, dropRule: DropRule?, modifier: Int) throws {
        guard diceCount >= 1 else {
            throw ParseError.invalidDiceCount
        }
        guard sides >= 2 else {
            throw ParseError.invalidSides
        }
        self.diceCount = diceCount
        self.sides = sides
        self.dropRule = dropRule
        self.modifier = modifier
    }

    init(parsing source: String) throws {
        let trimmed = source.replacing(" ", with: "")
        let pattern = #"^(\d+)d(\d+)([lLhH])?([+-]\d+)?$"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw ParseError.invalidFormat
        }

        let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: range) else {
            throw ParseError.invalidFormat
        }

        guard let diceCountRange = Range(match.range(at: 1), in: trimmed),
              let sidesRange = Range(match.range(at: 2), in: trimmed),
              let parsedDiceCount = Int(trimmed[diceCountRange]),
              let parsedSides = Int(trimmed[sidesRange]) else {
            throw ParseError.invalidFormat
        }

        let parsedDropRule: DropRule?
        if let dropRange = Range(match.range(at: 3), in: trimmed) {
            let symbol = trimmed[dropRange].lowercased()
            switch symbol {
            case "l":
                parsedDropRule = .lowest(1)
            case "h":
                parsedDropRule = .highest(1)
            default:
                throw ParseError.invalidFormat
            }
        } else {
            parsedDropRule = nil
        }

        let parsedModifier: Int
        if let modifierRange = Range(match.range(at: 4), in: trimmed) {
            guard let value = Int(trimmed[modifierRange]) else {
                throw ParseError.invalidModifier
            }
            parsedModifier = value
        } else {
            parsedModifier = 0
        }

        try self.init(
            diceCount: parsedDiceCount,
            sides: parsedSides,
            dropRule: parsedDropRule,
            modifier: parsedModifier
        )
    }

    var normalizedDescription: String {
        var text = "\(diceCount)d\(sides)"

        if let dropRule {
            switch dropRule {
            case .lowest:
                text += "L"
            case .highest:
                text += "H"
            }
        }

        if modifier > 0 {
            text += "+\(modifier)"
        } else if modifier < 0 {
            text += "\(modifier)"
        }

        return text
    }
}
