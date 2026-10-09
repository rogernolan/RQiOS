import SwiftUI

enum CharacterSectionPresentation: Equatable {
    case page
    case tile(width: CGFloat)

    var isTile: Bool {
        if case .tile = self { return true }
        return false
    }

    var usesCompactTileContent: Bool {
        if let tileWidth { return tileWidth < 280 }
        return false
    }

    var tileWidth: CGFloat? {
        if case let .tile(width) = self { return width }
        return nil
    }
}

private struct CharacterSectionPresentationKey: EnvironmentKey {
    static let defaultValue: CharacterSectionPresentation = .page
}

private struct CharacterSectionScrollToEditorKey: EnvironmentKey {
    static let defaultValue: (AnyHashable) -> Void = { _ in }
}

extension EnvironmentValues {
    var characterSectionPresentation: CharacterSectionPresentation {
        get { self[CharacterSectionPresentationKey.self] }
        set { self[CharacterSectionPresentationKey.self] = newValue }
    }

    var characterSectionScrollToEditor: (AnyHashable) -> Void {
        get { self[CharacterSectionScrollToEditorKey.self] }
        set { self[CharacterSectionScrollToEditorKey.self] = newValue }
    }
}

private struct SectionRuneBackgroundModifier: ViewModifier {
    @Environment(\.characterSectionPresentation) private var presentation
    let runeName: String
    let fixedRotation: Double?

    @ViewBuilder
    func body(content: Content) -> some View {
        if presentation.isTile {
            content
        } else {
            content.mainRuneBackground(runeName: runeName, fixedRotation: fixedRotation)
        }
    }
}

extension View {
    func sectionRuneBackground(runeName: String, fixedRotation: Double? = nil) -> some View {
        modifier(SectionRuneBackgroundModifier(runeName: runeName, fixedRotation: fixedRotation))
    }
}
