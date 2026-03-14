import Combine
import SwiftUI

final class EditableChipValueController: ObservableObject {
    @Published private(set) var activationID = 0

    func requestBeginEditing() {
        activationID += 1
    }
}

struct EditableChipValue: View {
    enum Mode {
        case singleValue
        case currentOfMax
    }

    enum MarkerPlacement {
        case hidden
        case inlineLeading
        case inlineTrailing
    }

    @Binding var value: Int

    let mode: Mode
    let displaySuffix: String
    let readOnlySuffix: String
    let showsEditingSuffix: Bool
    let isEnabled: Bool
    let textFieldWidth: CGFloat
    let completionButtonTravel: CGFloat
    let valueFont: Font
    let markerPlacement: MarkerPlacement
    let onBeginEditing: () -> Void
    let onEndEditing: () -> Void

    @ObservedObject var controller: EditableChipValueController
    @FocusState private var isFieldFocused: Bool
    @State private var draftValue: String = ""
    @State private var isEditingValue = false
    @State private var showsCompletionButton = false
    @State private var completionButtonScale: CGFloat = 0.25
    @State private var completionButtonOpacity: Double = 0.25
    @State private var valueContentOffset: CGFloat = 0

    private let accessoryWidth: CGFloat = 18
    private let completionButtonStartScale: CGFloat = 0.25
    private let completionButtonOvershootScale: CGFloat = 1.1
    private let completionButtonRestScale: CGFloat = 1
    private let completionButtonStartOpacity: Double = 0.25
    init(
        mode: Mode,
        value: Binding<Int>,
        displaySuffix: String = "",
        readOnlySuffix: String = "",
        showsEditingSuffix: Bool = true,
        isEnabled: Bool = true,
        textFieldWidth: CGFloat = 28,
        completionButtonTravel: CGFloat = 14,
        valueFont: Font = .body.weight(.semibold),
        markerPlacement: MarkerPlacement = .inlineTrailing,
        controller: EditableChipValueController = EditableChipValueController(),
        onBeginEditing: @escaping () -> Void = {},
        onEndEditing: @escaping () -> Void = {}
    ) {
        self._value = value
        self.mode = mode
        self.displaySuffix = displaySuffix
        self.readOnlySuffix = readOnlySuffix
        self.showsEditingSuffix = showsEditingSuffix
        self.isEnabled = isEnabled
        self.textFieldWidth = textFieldWidth
        self.completionButtonTravel = completionButtonTravel
        self.valueFont = valueFont
        self.markerPlacement = markerPlacement
        self._controller = ObservedObject(wrappedValue: controller)
        self.onBeginEditing = onBeginEditing
        self.onEndEditing = onEndEditing
    }

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if markerPlacement == .inlineLeading {
                accessorySlot
            }

            editableValueContent
                .offset(x: valueContentOffset)

            if markerPlacement != .inlineLeading {
                accessorySlot
            }
        }
        .onAppear {
            syncDraft()
            resetCompletionButtonVisuals()
        }
        .onChange(of: value) { _, _ in
            guard isEditingValue == false else { return }
            syncDraft()
        }
        .onChange(of: isEnabled) { _, enabled in
            if enabled == false, isEditingValue {
                finishEditing()
            }
        }
        .onChange(of: isFieldFocused) { _, isFocused in
            if isFocused == false, isEditingValue {
                finishEditing()
            }
        }
        .onChange(of: controller.activationID) { _, _ in
            beginEditingIfEnabled()
        }
    }

    @ViewBuilder
    private var accessorySlot: some View {
        Group {
            if showsCompletionButton {
                Button {
                    completeEditingFromButton()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
                .scaleEffect(completionButtonScale)
                .opacity(completionButtonOpacity)
                .allowsHitTesting(isEditingValue)
            } else if isEnabled && markerPlacement != .hidden {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            } else {
                Color.clear
            }
        }
        .frame(width: accessorySlotWidth, alignment: .center)
    }

    private var accessorySlotWidth: CGFloat {
        if showsCompletionButton || (isEnabled && markerPlacement != .hidden) {
            accessoryWidth
        } else {
            0
        }
    }

    @ViewBuilder
    private var editableValueContent: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            if isEditingValue {
                TextField("", text: $draftValue)
                    .font(valueFont)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .frame(minWidth: textFieldWidth)
                    .focused($isFieldFocused)
                    .onChange(of: draftValue) { _, newValue in
                        applyDraft(newValue)
                    }
            } else {
                displayValue
            }

            suffixView(isEditing: isEditingValue)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            beginEditingIfEnabled()
        }
    }

    private var displayValue: some View {
        Text("\(value)")
            .font(valueFont)
            .monospacedDigit()
    }

    @ViewBuilder
    private func suffixView(isEditing: Bool) -> some View {
        switch mode {
        case .singleValue:
            if displaySuffix.isEmpty == false && (isEditing == false || showsEditingSuffix) {
                Text(displaySuffix)
                    .font(valueFont)
                    .monospacedDigit()
                    .foregroundStyle(isEditing ? .secondary : .primary)
            }
        case .currentOfMax:
            Text(readOnlySuffix)
                .font(valueFont)
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
    }

    private func beginEditingIfEnabled() {
        guard isEnabled, isEditingValue == false else { return }
        syncDraft()
        isEditingValue = true
        showCompletionButtonAnimated()
        onBeginEditing()
        DispatchQueue.main.async {
            isFieldFocused = true
        }
    }

    private func finishEditing() {
        applyDraft(draftValue)
        syncDraft()
        isEditingValue = false
        isFieldFocused = false
        hideCompletionButtonAnimated()
        onEndEditing()
    }

    private func completeEditingFromButton() {
        finishEditing()
    }

    private func syncDraft() {
        draftValue = String(value)
    }

    private func applyDraft(_ draft: String) {
        let digitsOnly = draft.filter(\.isNumber)
        if digitsOnly != draft {
            draftValue = digitsOnly
        }

        if digitsOnly.isEmpty {
            value = 0
        } else if let parsedValue = Int(digitsOnly) {
            value = parsedValue
        }
    }

    private func showCompletionButtonAnimated() {
        showsCompletionButton = true
        resetCompletionButtonVisuals()

        withAnimation(.spring(duration: 0.34, bounce: 0.42)) {
            completionButtonScale = completionButtonOvershootScale
            completionButtonOpacity = 1
            valueContentOffset = -completionButtonTravel
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            guard showsCompletionButton else { return }

            withAnimation(.spring(duration: 0.18, bounce: 0.12)) {
                completionButtonScale = completionButtonRestScale
            }
        }
    }

    private func hideCompletionButtonAnimated() {
        withAnimation(.spring(duration: 0.24, bounce: 0.1)) {
            completionButtonScale = completionButtonStartScale
            completionButtonOpacity = completionButtonStartOpacity
            valueContentOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard isEditingValue == false else { return }
            showsCompletionButton = false
        }
    }

    private func resetCompletionButtonVisuals() {
        completionButtonScale = completionButtonStartScale
        completionButtonOpacity = completionButtonStartOpacity
        valueContentOffset = 0
    }
}
