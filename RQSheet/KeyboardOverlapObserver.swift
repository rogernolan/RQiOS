import Combine
import SwiftUI
import UIKit

@MainActor
final class KeyboardOverlapObserver: ObservableObject {
    @Published private(set) var keyboardFrame = CGRect.null
    private var cancellables: Set<AnyCancellable> = []

    init() {
        let frameChanges = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardDidChangeFrameNotification))
            .compactMap { notification in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            }
        let hides = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGRect.null }
        frameChanges
            .merge(with: hides)
            .receive(on: RunLoop.main)
            .sink { [weak self] frame in self?.keyboardFrame = frame }
            .store(in: &cancellables)
    }

    func bottomInset(in viewport: CGRect) -> CGFloat {
        Self.bottomInset(viewport: viewport, keyboard: keyboardFrame)
    }

    nonisolated static func bottomInset(viewport: CGRect, keyboard: CGRect) -> CGFloat {
        guard !viewport.isNull, !keyboard.isNull,
              keyboard.maxY >= viewport.maxY - 1,
              keyboard.minX <= viewport.minX + viewport.width * 0.2,
              keyboard.maxX >= viewport.maxX - viewport.width * 0.2 else { return 0 }
        return max(0, min(viewport.maxY, keyboard.maxY) - max(viewport.minY, keyboard.minY))
    }
}
