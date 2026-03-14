import Combine
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class KeyboardHeightObserver: ObservableObject {
    @Published private(set) var height: CGFloat = 0

    private var cancellables: Set<AnyCancellable> = []

    init() {
        #if canImport(UIKit)
        let frameChanges = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap(Self.keyboardHeight(from:))
            .receive(on: RunLoop.main)

        frameChanges
            .sink { [weak self] newHeight in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self?.height = newHeight
                }
            }
            .store(in: &cancellables)
        #endif
    }

    var contentInset: CGFloat {
        max(0, height - 88)
    }

    #if canImport(UIKit)
    private static func keyboardHeight(from notification: Notification) -> CGFloat? {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return 0
        }

        let screenHeight = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .screen
            .bounds
            .height ?? UIScreen.main.bounds.height
        return max(0, screenHeight - frame.minY)
    }
    #endif
}
