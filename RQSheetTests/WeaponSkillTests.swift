import Foundation
import Testing
@testable import RQSheet

struct WeaponSkillTests {
    @Test
    func weaponSkillAllowsMissingCombatFields() {
        let weapon = WeaponSkill(
            name: "Sling",
            damage: "1d6",
            hpMax: nil,
            hpCurrent: nil,
            enc: nil,
            strikeRank: "missile",
            type: nil
        )

        #expect(weapon.hpMax == nil)
        #expect(weapon.hpCurrent == nil)
        #expect(weapon.enc == nil)
        #expect(weapon.strikeRank == "missile")
        #expect(weapon.type == nil)
    }

    @Test
    func weaponSkillPreservesStringStrikeRank() {
        let weapon = WeaponSkill(
            name: "Broadsword",
            damage: "1d8+1",
            strikeRank: "DEX+SIZ",
            type: .slashing
        )

        #expect(weapon.strikeRank == "DEX+SIZ")
    }
}
