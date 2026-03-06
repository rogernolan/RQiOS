import Testing
@testable import RQSheet

struct StatRollProfileTests {
    @Test
    func defaultProfileUsesExpectedExpressions() {
        let profile = StatRollProfile.defaultHuman

        #expect(profile.expression(for: .siz).normalizedDescription == "2d6+6")
        #expect(profile.expression(for: .int).normalizedDescription == "2d6+6")

        #expect(profile.expression(for: .str).normalizedDescription == "4d6L")
        #expect(profile.expression(for: .con).normalizedDescription == "4d6L")
        #expect(profile.expression(for: .dex).normalizedDescription == "4d6L")
        #expect(profile.expression(for: .pow).normalizedDescription == "4d6L")
        #expect(profile.expression(for: .cha).normalizedDescription == "4d6L")
    }
}
