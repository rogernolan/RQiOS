import SwiftUI
import Testing
@testable import RQSheet

struct EquipmentEditorViewTests {
    @Test
    @MainActor
    func editorCanBeCreatedForAnEquipmentItem() {
        let item = CharacterEquipmentItem(
            name: "Shield",
            encumbrance: 2,
            notes: "Bronze",
            isCurrentlyEquipped: true
        )

        let view = EquipmentEditorView(item: item)

        _ = view.body
        #expect(item.name == "Shield")
        #expect(item.encumbrance == 2)
        #expect(item.notes == "Bronze")
    }
}
