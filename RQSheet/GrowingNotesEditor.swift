import SwiftUI
import UIKit

/// Fits the note at the proposed tile width; the containing page owns scrolling.
struct GrowingNotesEditor: UIViewRepresentable {
    @Binding var text: String
    var minimumHeight: CGFloat = 180

    func makeUIView(context: Context) -> GrowingNotesTextView {
        let view = GrowingNotesTextView()
        view.delegate = context.coordinator
        context.coordinator.textView = view
        view.onLayout = { [weak coordinator = context.coordinator] in
            coordinator?.scheduleCaretVisibility()
        }
        return view
    }

    func updateUIView(_ view: GrowingNotesTextView, context: Context) {
        context.coordinator.editor = self
        view.minimumHeight = minimumHeight
        view.replaceTextPreservingSelection(text)
        view.updatePlaceholder()
        context.coordinator.scheduleCaretVisibility()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: GrowingNotesTextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0, width.isFinite else { return nil }
        let fitted = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: max(minimumHeight, ceil(fitted.height)))
    }

    func makeCoordinator() -> Coordinator { Coordinator(editor: self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var editor: GrowingNotesEditor
        weak var textView: GrowingNotesTextView?
        private var keyboardFrameInScreen: CGRect?
        private var isCaretUpdateScheduled = false

        init(editor: GrowingNotesEditor) {
            self.editor = editor
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        deinit { NotificationCenter.default.removeObserver(self) }

        func textViewDidChange(_ textView: UITextView) {
            editor.text = textView.text
            self.textView?.updatePlaceholder()
            textView.invalidateIntrinsicContentSize()
            scheduleCaretVisibility()
        }

        func textViewDidChangeSelection(_ textView: UITextView) { scheduleCaretVisibility() }
        func textViewDidBeginEditing(_ textView: UITextView) { scheduleCaretVisibility() }

        @objc private func keyboardChanged(_ notification: Notification) {
            keyboardFrameInScreen = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            scheduleCaretVisibility()
        }

        @objc private func keyboardHidden(_ notification: Notification) {
            keyboardFrameInScreen = nil
            scheduleCaretVisibility()
        }

        func scheduleCaretVisibility() {
            guard !isCaretUpdateScheduled, textView?.isFirstResponder == true else { return }
            isCaretUpdateScheduled = true
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.isCaretUpdateScheduled = false
                self.ensureCaretVisible()
            }
        }

        private func ensureCaretVisible() {
            guard let textView, textView.isFirstResponder,
                  let selection = textView.selectedTextRange,
                  let window = textView.window else { return }
            var ancestor = textView.superview
            while let view = ancestor, !(view is UIScrollView) { ancestor = view.superview }
            guard let page = ancestor as? UIScrollView else { return }

            let caret = textView.convert(textView.caretRect(for: selection.end), to: window)
            let visible = page.convert(page.bounds.inset(by: page.adjustedContentInset), to: window)
                .intersection(window.bounds.inset(by: window.safeAreaInsets))
            guard !visible.isNull else { return }
            var bottom = visible.maxY
            if let keyboardFrameInScreen {
                let keyboard = window.convert(keyboardFrameInScreen, from: window.screen.coordinateSpace)
                if keyboard.intersects(visible), keyboard.minX < caret.maxX, keyboard.maxX > caret.minX {
                    bottom = min(bottom, keyboard.minY)
                }
            }
            let margin: CGFloat = 16
            let delta: CGFloat
            if caret.maxY + margin > bottom {
                delta = caret.maxY + margin - bottom
            } else if caret.minY - margin < visible.minY {
                delta = caret.minY - margin - visible.minY
            } else {
                return
            }
            let lowerLimit = -page.adjustedContentInset.top
            let upperLimit = max(lowerLimit, page.contentSize.height - page.bounds.height + page.adjustedContentInset.bottom)
            let offset = min(upperLimit, max(lowerLimit, page.contentOffset.y + delta))
            if abs(offset - page.contentOffset.y) > 1 {
                page.setContentOffset(CGPoint(x: page.contentOffset.x, y: offset), animated: false)
            }
        }
    }
}

final class GrowingNotesTextView: UITextView {
    var minimumHeight: CGFloat = 180
    var onLayout: (() -> Void)?
    private let placeholder = UILabel()
    private var measuredWidth: CGFloat = 0

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        backgroundColor = .clear
        isScrollEnabled = false
        font = .preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        self.textContainer.lineFragmentPadding = 5
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        accessibilityIdentifier = "notes.editor"
        accessibilityLabel = "Notes"
        placeholder.text = "Add notes"
        placeholder.textColor = .secondaryLabel
        placeholder.font = .preferredFont(forTextStyle: .body)
        placeholder.adjustsFontForContentSizeCategory = true
        placeholder.isUserInteractionEnabled = false
        placeholder.isAccessibilityElement = false
        addSubview(placeholder)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func replaceTextPreservingSelection(_ newText: String) {
        // Matching text must stay untouched so typing, IME composition and rotation
        // do not reset the insertion point or an active selection.
        guard text != newText else { return }
        let selection = selectedRange
        text = newText
        let length = (newText as NSString).length
        let location = min(selection.location, length)
        selectedRange = NSRange(location: location, length: min(selection.length, length - location))
        invalidateIntrinsicContentSize()
    }

    func updatePlaceholder() {
        placeholder.isHidden = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    override var intrinsicContentSize: CGSize {
        guard bounds.width > 0 else { return CGSize(width: UIView.noIntrinsicMetric, height: minimumHeight) }
        let fitted = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: max(minimumHeight, ceil(fitted.height)))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholder.frame = CGRect(
            x: textContainerInset.left + textContainer.lineFragmentPadding,
            y: textContainerInset.top,
            width: max(0, bounds.width - textContainerInset.left - textContainerInset.right - 2 * textContainer.lineFragmentPadding),
            height: placeholder.intrinsicContentSize.height
        )
        if measuredWidth != bounds.width {
            measuredWidth = bounds.width
            invalidateIntrinsicContentSize()
        }
        onLayout?()
    }
}
