import CoreGraphics
import Testing
@testable import RQSheet

struct CombatViewTests {
    @Test
    func combatViewConfigExposesHeaderAndPanelMetrics() {
        #expect(CombatViewConfiguration.minimumPanelHeight == CGFloat(300))
        #expect(CombatViewConfiguration.panelHeightMultiplier == CGFloat(0.82))
        #expect(CombatViewConfiguration.topPadding == CGFloat(4))
        #expect(CombatViewConfiguration.horizontalPadding == CGFloat(16))
        #expect(CombatViewConfiguration.minimumBottomPadding == CGFloat(16))
        #expect(CombatViewConfiguration.hitLocationVerticalOffset == CGFloat(-28))
    }

    @Test
    func combatWeaponRowConfigExposesCompactLayoutMetrics() {
        #expect(CombatWeaponRowConfiguration.listHorizontalPadding == CGFloat(10))
        #expect(CombatWeaponRowConfiguration.listTopPadding == CGFloat(4))
        #expect(CombatWeaponRowConfiguration.listBottomPadding == CGFloat(8))
        #expect(CombatWeaponRowConfiguration.rowSpacing == CGFloat(5))
        #expect(CombatWeaponRowConfiguration.basePercentageWidth == CGFloat(38))
        #expect(CombatWeaponRowConfiguration.experienceCheckWidth == CGFloat(24))
        #expect(CombatWeaponRowConfiguration.strikeRankWidth == CGFloat(56))
        #expect(CombatWeaponRowConfiguration.damageWidth == CGFloat(54))
        #expect(CombatWeaponRowConfiguration.disclosureSize == CGFloat(22))
    }

    @Test
    func combatHitPointsChipUsesSharedEditorMetrics() {
        #expect(CombatHitPointsConfiguration.completionButtonTravel == CGFloat(8))
        #expect(CombatHitPointsConfiguration.minWidth == CGFloat(104))
    }

    @Test
    func combatFormattingHandlesOptionalAndBlankWeaponFields() {
        let weapon = Weapon(
            character: nil,
            name: "Broadsword",
            basePercentage: 65,
            experienceCheck: false,
            damage: "1d8+1",
            hpMax: 12,
            hpCurrent: 8,
            enc: 2,
            strikeRank: "",
            type: .slashing,
            range: "  ",
            isEquipped: false
        )

        #expect(CombatViewFormatting.weaponHPText(weapon) == "12/8")
        #expect(CombatViewFormatting.weaponEncText(weapon) == "2")
        #expect(CombatViewFormatting.weaponStrikeRankText(weapon) == "-")
        #expect(CombatViewFormatting.weaponTypeText(weapon) == WeaponType.slashing.rawValue)
        #expect(CombatViewFormatting.weaponRangeText(weapon) == nil)

        weapon.strikeRank = "3"
        weapon.range = "S"

        #expect(CombatViewFormatting.weaponStrikeRankText(weapon) == "3")
        #expect(CombatViewFormatting.weaponRangeText(weapon) == "S")
    }

    @Test
    func combatFormattingFallsBackForMissingOptionalFields() {
        let weapon = Weapon(
            character: nil,
            name: "Club",
            basePercentage: 45,
            experienceCheck: false,
            damage: "1d6",
            hpMax: nil,
            hpCurrent: nil,
            enc: nil,
            strikeRank: "",
            type: nil,
            range: "",
            isEquipped: false
        )

        #expect(CombatViewFormatting.weaponHPText(weapon) == "-")
        #expect(CombatViewFormatting.weaponEncText(weapon) == "-")
        #expect(CombatViewFormatting.weaponTypeText(weapon) == "-")
        #expect(CombatViewFormatting.weaponRangeText(weapon) == nil)
    }
}
