import Foundation

protocol DiceRoller {
    func roll<R: RandomNumberGenerator>(_ expression: DiceExpression, using rng: inout R) -> DiceRollResult
}

struct DiceRollResult: Equatable {
    let rolls: [Int]
    let kept: [Int]
    let dropped: [Int]
    let subtotal: Int
    let modifier: Int
    let total: Int
}

struct DefaultDiceRoller: DiceRoller {
    func roll<R: RandomNumberGenerator>(_ expression: DiceExpression, using rng: inout R) -> DiceRollResult {
        let rolls = (0..<expression.diceCount).map { _ in
            Int(rng.next() % UInt64(expression.sides)) + 1
        }

        var kept = rolls
        var dropped: [Int] = []

        if let dropRule = expression.dropRule {
            switch dropRule {
            case .lowest(let count):
                for _ in 0..<count {
                    guard let index = kept.enumerated().min(by: { lhs, rhs in
                        if lhs.element == rhs.element {
                            return lhs.offset < rhs.offset
                        }
                        return lhs.element < rhs.element
                    })?.offset else {
                        break
                    }
                    dropped.append(kept.remove(at: index))
                }
            case .highest(let count):
                for _ in 0..<count {
                    guard let index = kept.enumerated().max(by: { lhs, rhs in
                        if lhs.element == rhs.element {
                            return lhs.offset > rhs.offset
                        }
                        return lhs.element < rhs.element
                    })?.offset else {
                        break
                    }
                    dropped.append(kept.remove(at: index))
                }
            }
        }

        let subtotal = kept.reduce(0, +)
        let total = subtotal + expression.modifier

        return DiceRollResult(
            rolls: rolls,
            kept: kept,
            dropped: dropped,
            subtotal: subtotal,
            modifier: expression.modifier,
            total: total
        )
    }
}

struct FixedSequenceRNG: RandomNumberGenerator {
    private let values: [UInt64]
    private var index = 0

    init(values: [Int]) {
        self.values = values.map { UInt64(max(1, $0)) }
    }

    mutating func next() -> UInt64 {
        guard values.isEmpty == false else {
            return 0
        }

        let value = values[index % values.count]
        index += 1
        return value - 1
    }
}
