import Testing
@testable import RQSheet

struct DiceExpressionParserTests {
    @Test
    func parsesStandardExpression() throws {
        let expression = try DiceExpression(parsing: "3d6+4")
        #expect(expression.diceCount == 3)
        #expect(expression.sides == 6)
        #expect(expression.dropRule == nil)
        #expect(expression.modifier == 4)
    }

    @Test
    func parsesDropLowestAndHighestCaseInsensitively() throws {
        let low = try DiceExpression(parsing: "4d6l+1")
        let high = try DiceExpression(parsing: "3d8H-1")

        #expect(low.dropRule == .lowest(1))
        #expect(high.dropRule == .highest(1))
        #expect(high.modifier == -1)
    }

    @Test
    func rejectsMalformedInput() {
        #expect(throws: DiceExpression.ParseError.self) {
            _ = try DiceExpression(parsing: "d6")
        }
    }
}
