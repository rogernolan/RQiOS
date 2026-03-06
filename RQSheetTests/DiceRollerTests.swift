import Testing
@testable import RQSheet

struct DiceRollerTests {
    @Test
    func rollsAndDropsLowestCorrectly() throws {
        var rng = FixedSequenceRNG(values: [1, 6, 4, 3])
        let expression = try DiceExpression(parsing: "4d6L+1")

        let result = DefaultDiceRoller().roll(expression, using: &rng)

        #expect(result.rolls == [1, 6, 4, 3])
        #expect(result.dropped == [1])
        #expect(result.kept == [6, 4, 3])
        #expect(result.total == 14)
    }

    @Test
    func rollsAndDropsHighestCorrectly() throws {
        var rng = FixedSequenceRNG(values: [8, 2, 5])
        let expression = try DiceExpression(parsing: "3d8H-1")

        let result = DefaultDiceRoller().roll(expression, using: &rng)

        #expect(result.dropped == [8])
        #expect(result.kept == [2, 5])
        #expect(result.total == 6)
    }
}
