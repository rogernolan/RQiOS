import Foundation
import Testing
@testable import RQSheet

struct WeaponTests {
    @Test
    func weaponAllowsMissingCombatFields() {
        let weapon = Weapon(
            name: "Sling",
            damage: "1d6",
            hpMax: nil,
            hpCurrent: nil,
            enc: nil,
            strikeRank: "missile",
            type: nil,
            range: "",
            isEquipped: false
        )

        #expect(weapon.hpMax == nil)
        #expect(weapon.hpCurrent == nil)
        #expect(weapon.enc == nil)
        #expect(weapon.strikeRank == "missile")
        #expect(weapon.type == nil)
        #expect(weapon.range == "")
        #expect(weapon.isEquipped == false)
    }

    @Test
    func weaponPreservesStringStrikeRank() {
        let weapon = Weapon(
            name: "Broadsword",
            damage: "1d8+1",
            strikeRank: "DEX+SIZ",
            type: .slashing,
            range: "",
            isEquipped: false
        )

        #expect(weapon.strikeRank == "DEX+SIZ")
    }
}
