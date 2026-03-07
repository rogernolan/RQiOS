import Foundation
import Testing
@testable import RQSheet

struct EquipmentViewTests {
    @Test
    func equipmentViewDoesNotDeclareItsOwnNavigationStack() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/EquipmentView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("NavigationStack {") == false)
    }

    @Test
    func equipmentRowCardsDoNotUseHeavyOpaqueBackground() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/EquipmentView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("opacity(0.68)") == false)
    }
}
