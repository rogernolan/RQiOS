import CoreGraphics
import SwiftUI
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
        #expect(RuneChipLayoutMetrics.percentageContentLeadingInset > .zero)
    }

    @Test
    func displayAndEditUseTheSameContentWidth() {
        #expect(RuneChipLayoutMetrics.percentageDisplayWidth == RuneChipLayoutMetrics.percentageEditorWidth)
    }

    @Test
    func editorInsetKeepsFieldOffChipEdge() {
        #expect(RuneChipLayoutMetrics.percentageEditorHorizontalInset > .zero)
        #expect(RuneChipLayoutMetrics.percentageEditorWidth <= RuneChipLayoutMetrics.percentageSlotWidth(for: true))
    }

    @Test
    func runeEditingChromeFitsWithoutGrowingTheChip() {
        #expect(RuneChipLayoutMetrics.percentageDisplayWidth + RuneChipLayoutMetrics.checkboxSlotWidth <= RuneChipLayoutMetrics.chipWidth)
    }

    @Test
    func runeChipLeavesRoomForInlineMarkerAndLargerValueSlot() {
        #expect(RuneChipLayoutMetrics.percentageDisplayWidth >= 48)
        #expect(RuneChipLayoutMetrics.chipWidth >= 112)
    }

    @Test
    func runePentagramUsesExpandedRadiusForWiderChips() {
        #expect(RuneChipLayoutMetrics.elementalRadiusMultiplier >= 0.44)
    }

    @Test
    func upperSideRunesShiftSlightlyHigherThanBaseRing() {
        #expect(RuneChipLayoutMetrics.upperSideNodeVerticalOffset < .zero)
    }

    @Test
    func idleRunePercentageWidthClearsThreeDigitDisplayWithoutClipping() {
        #expect(RuneChipLayoutMetrics.percentageDisplayWidth >= 52)
        #expect(RuneChipLayoutMetrics.percentageSlotWidth(for: false) >= 69)
    }

    @Test
    func pairedPowerRuneChipsReserveMoreWidthThanElementalChips() {
        #expect(RuneChipLayoutMetrics.pairedChipWidth > RuneChipLayoutMetrics.chipWidth)
        #expect(RuneChipLayoutMetrics.pairedPercentageSlotWidth(for: false) > RuneChipLayoutMetrics.percentageSlotWidth(for: false))
    }

    @Test
    func runeViewConfigExposesPaddingAndAnchors() {
        #expect(RuneViewConfiguration.horizontalPadding == 16)
        #expect(RuneViewConfiguration.topPadding == 8)
        #expect(RuneViewConfiguration.scrollAnchor == .center)
    }
}
