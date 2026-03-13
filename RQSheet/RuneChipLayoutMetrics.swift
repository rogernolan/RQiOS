import CoreGraphics

enum RuneChipLayoutMetrics {
    static let chipWidth: CGFloat = 112
    static let chipHeight: CGFloat = 58
    static let chipHorizontalPadding: CGFloat = 6
    static let chipVerticalPadding: CGFloat = 5

    static let titleSpacing: CGFloat = 4
    static let checkboxSlotWidth: CGFloat = 16
    static let checkboxSlotHeight: CGFloat = 16

    static let valueRowSpacing: CGFloat = 6
    static let runeIconSize: CGFloat = 26

    static let percentageContentLeadingInset: CGFloat = 5
    static let percentageDisplayWidth: CGFloat = 48
    static let percentageEditorWidth: CGFloat = 48
    static let percentageEditorHeight: CGFloat = 28
    static let percentageEditorHorizontalInset: CGFloat = 2

    private static let sharedPercentageSlotWidth: CGFloat = 65

    static func percentageSlotWidth(for _: Bool) -> CGFloat {
        sharedPercentageSlotWidth
    }
}
