import CoreGraphics
import Testing
@testable import RQSheet

struct RuneChipLayoutMetricsTests {
    @Test
    func percentageSlotWidthIsSharedAcrossModes() {
        #expect(RuneChipLayoutMetrics.percentageSlotWidth(for: false) == RuneChipLayoutMetrics.percentageSlotWidth(for: true))
    }

    @Test
    func checkboxSlotHasFixedVisibleWidth() {
        #expect(RuneChipLayoutMetrics.checkboxSlotWidth > .zero)
    }

    @Test
    func chipHeightLeavesRoomForEditingWithoutResizing() {
        #expect(RuneChipLayoutMetrics.chipHeight > RuneChipLayoutMetrics.percentageEditorHeight)
    }

    @Test
    func editorContentFitsWithinTheTrailingAnchor() {
        #expect(
            RuneChipLayoutMetrics.percentageContentLeadingInset
                + RuneChipLayoutMetrics.percentageEditorWidth
                <= RuneChipLayoutMetrics.percentageSlotWidth(for: true)
        )
    }

    @Test
    func trailingAnchorLeavesExpansionRoomToTheLeft() {
        #expect(
            RuneChipLayoutMetrics.percentageSlotWidth(for: true)
                - RuneChipLayoutMetrics.percentageContentLeadingInset
                - RuneChipLayoutMetrics.percentageEditorWidth
                >= 12
        )
    }

    @Test
    func percentageContentIsInsetFromTheSlotLeadingEdge() {
        #expect(
            RuneChipLayoutMetrics.percentageContentLeadingInset
                > .zero
        )
    }

    @Test
    func displayAndEditUseTheSameContentWidth() {
        #expect(
            RuneChipLayoutMetrics.percentageDisplayWidth
                == RuneChipLayoutMetrics.percentageEditorWidth
        )
    }

    @Test
    func editorInsetKeepsFieldOffChipEdge() {
        #expect(RuneChipLayoutMetrics.percentageEditorHorizontalInset > .zero)
        #expect(
            RuneChipLayoutMetrics.percentageEditorWidth
                <= RuneChipLayoutMetrics.percentageSlotWidth(for: true)
        )
    }
}
