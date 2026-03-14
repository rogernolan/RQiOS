import CoreGraphics

enum RuneChipLayoutMetrics {
    static let chipWidth: CGFloat = 112
    static let pairedChipWidth: CGFloat = 124
    static let chipHeight: CGFloat = 58
    static let chipHorizontalPadding: CGFloat = 6
    static let chipVerticalPadding: CGFloat = 5
    static let elementalRadiusMultiplier: CGFloat = 0.44
    static let upperSideNodeVerticalOffset: CGFloat = -8

    static let titleSpacing: CGFloat = 4
    static let checkboxSlotWidth: CGFloat = 16
    static let checkboxSlotHeight: CGFloat = 16

    static let valueRowSpacing: CGFloat = 6
    static let runeIconSize: CGFloat = 26

    static let percentageContentLeadingInset: CGFloat = 5
    static let percentageDisplayWidth: CGFloat = 52
    static let percentageEditorWidth: CGFloat = 52
    static let pairedPercentageDisplayWidth: CGFloat = 60
    static let pairedPercentageEditorWidth: CGFloat = 60
    static let percentageEditorHeight: CGFloat = 28
    static let percentageEditorHorizontalInset: CGFloat = 2

    private static let sharedPercentageSlotWidth: CGFloat = 70
    private static let pairedSharedPercentageSlotWidth: CGFloat = 80

    static func percentageSlotWidth(for _: Bool) -> CGFloat {
        sharedPercentageSlotWidth
    }

    static func pairedPercentageSlotWidth(for _: Bool) -> CGFloat {
        pairedSharedPercentageSlotWidth
    }
}
