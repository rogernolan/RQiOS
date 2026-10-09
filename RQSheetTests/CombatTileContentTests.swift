import SwiftUI
import Testing
import UIKit
@testable import RQSheet

@MainActor
struct CombatTileContentTests {
    @Test func compactLocationsUseMeasuredHeightsAndRemainInsideTheirTile() {
        let sizes = HitLocation.allCases.enumerated().map { CGSize(width: 85, height: 80 + CGFloat($0.offset * 3)) }
        let geometry = CombatHitLocationTileGeometry(width: 180, isCompact: true, cardSizes: sizes)
        for (index, size) in sizes.enumerated() {
            let position = geometry.position(of: index)
            #expect(position.x - size.width / 2 >= 0)
            #expect(position.x + size.width / 2 <= geometry.width)
            #expect(position.y - size.height / 2 >= 0)
            #expect(position.y + size.height / 2 <= geometry.height)
            if index > 0 {
                let precedingBottom = geometry.position(of: index - 1).y + sizes[index - 1].height / 2
                #expect(position.y - size.height / 2 == precedingBottom + 8)
            }
        }
    }

    @Test func diagramLocationsStayInsideMeasuredBoundsWithLargerCards() {
        let sizes = Array(repeating: CGSize(width: 85, height: 122), count: HitLocation.allCases.count)
        let geometry = CombatHitLocationTileGeometry(width: 360, isCompact: false, cardSizes: sizes)
        #expect(geometry.height > 300)
        for (index, size) in sizes.enumerated() {
            let position = geometry.position(of: index)
            #expect(position.x - size.width / 2 >= 0)
            #expect(position.x + size.width / 2 <= geometry.width)
            #expect(position.y - size.height / 2 >= 0)
            #expect(position.y + size.height / 2 <= geometry.height)
        }
    }

    @Test(arguments: [CGFloat(180), CGFloat(360)])
    func expandedDetailsGrowToFitLongRangeAtCompactAndRegularWidths(width: CGFloat) {
        let shortHeight = heightOfExpandedWeapon(width: width, range: "20m", typeSize: .large)
        let longRange = Array(repeating: "Thrown at short range and fired at greater distance.", count: 12).joined(separator: " ")
        let longHeight = heightOfExpandedWeapon(width: width, range: longRange, typeSize: .large)
        #expect(longHeight > shortHeight + 50)
    }

    @Test func accessibilityTextCanIncreaseExpandedDetailHeight() {
        let range = "A medium length range description that wraps onto several lines."
        let regular = heightOfExpandedWeapon(width: 180, range: range, typeSize: .large)
        let enlarged = heightOfExpandedWeapon(width: 180, range: range, typeSize: .accessibility3)
        #expect(enlarged > regular)
    }

    private func heightOfExpandedWeapon(width: CGFloat, range: String, typeSize: DynamicTypeSize) -> CGFloat {
        let weapon = Weapon(character: nil, name: "Spear", basePercentage: 50, experienceCheck: false,
                            damage: "1d6", hpMax: 10, hpCurrent: 10, enc: 1, strikeRank: "3",
                            type: .impaling, range: range, isEquipped: true)
        let view = WeaponRowCard(weapon: weapon, isExpanded: true, isActionInteractionEnabled: true,
                                 onSelect: {}, onToggleExperience: {}, onToggleExpanded: {}, onToggleEquipped: {})
            .environment(\.characterSectionPresentation, .tile(width: width))
            .dynamicTypeSize(typeSize)
        let controller = UIHostingController(rootView: view)
        return controller.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude)).height
    }
}
