import CoreGraphics
import Testing
@testable import RQSheet

struct EditableChipValueTests {
    @Test
    func configExposesSupportedModes() {
        #expect(EditableChipValueConfiguration.supportedModes == [.singleValue, .currentOfMax])
    }

    @Test
    func configExposesMarkerPlacements() {
        #expect(EditableChipValueConfiguration.supportedMarkerPlacements == [.hidden, .inlineLeading, .inlineTrailing])
    }

    @Test
    func configIncludesCompletionAnimationConstants() {
        #expect(EditableChipValueConfiguration.completionButtonStartScale == CGFloat(0.25))
        #expect(EditableChipValueConfiguration.completionButtonOvershootScale == CGFloat(1.1))
        #expect(EditableChipValueConfiguration.completionButtonRestScale == CGFloat(1))
        #expect(EditableChipValueConfiguration.completionButtonStartOpacity == 0.25)
        #expect(EditableChipValueConfiguration.defaultCompletionButtonTravel == CGFloat(14))
    }

    @Test
    func hiddenMarkerModeDoesNotReserveIdleAccessoryWidth() {
        #expect(EditableChipValueConfiguration.accessorySlotWidth(showsCompletionButton: false, isEnabled: true, markerPlacement: .hidden) == 0)
        #expect(EditableChipValueConfiguration.accessorySlotWidth(showsCompletionButton: false, isEnabled: true, markerPlacement: .inlineTrailing) == EditableChipValueConfiguration.accessoryWidth)
        #expect(EditableChipValueConfiguration.accessorySlotWidth(showsCompletionButton: true, isEnabled: true, markerPlacement: .hidden) == EditableChipValueConfiguration.accessoryWidth)
    }

    @Test
    func displayAndEditingUseSharedLayoutConstants() {
        #expect(EditableChipValueConfiguration.outerRowSpacing == CGFloat(4))
        #expect(EditableChipValueConfiguration.innerRowSpacing == CGFloat(2))
    }
}
