import Foundation

enum CharacteristicKey: CaseIterable {
    case str
    case con
    case siz
    case dex
    case int
    case pow
    case cha

    var modelCharacteristic: RQCharacter.Characteristic {
        switch self {
        case .str:
            return .str
        case .con:
            return .con
        case .siz:
            return .siz
        case .dex:
            return .dex
        case .int:
            return .int
        case .pow:
            return .pow
        case .cha:
            return .cha
        }
    }
}

struct StatRollProfile {
    private let expressions: [CharacteristicKey: DiceExpression]

    init(expressions: [CharacteristicKey: DiceExpression]) {
        self.expressions = expressions
    }

    func expression(for key: CharacteristicKey) -> DiceExpression {
        guard let expression = expressions[key] else {
            preconditionFailure("Missing dice expression for \(key)")
        }
        return expression
    }

    static let defaultHuman = StatRollProfile(
        expressions: [
            .siz: parse("2d6+6"),
            .int: parse("2d6+6"),
            .str: parse("4d6L"),
            .con: parse("4d6L"),
            .dex: parse("4d6L"),
            .pow: parse("4d6L"),
            .cha: parse("4d6L"),
        ]
    )

    private static func parse(_ source: String) -> DiceExpression {
        do {
            return try DiceExpression(parsing: source)
        } catch {
            preconditionFailure("Invalid default dice expression: \(source)")
        }
    }
}
