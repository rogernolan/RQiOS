import Foundation

nonisolated enum WorkspaceLayout {
    static func contentWidth(availableWidth: CGFloat, isPad: Bool) -> CGFloat {
        isPad ? min(availableWidth, 900) : availableWidth
    }
}

nonisolated struct IPadSummaryProfileLayout {
    let portraitSize: CGFloat
    let usesHorizontalLayout: Bool

    init(availableWidth: CGFloat) {
        portraitSize = min(144, max(80, availableWidth / 3))
        usesHorizontalLayout = availableWidth >= 420
    }
}
