import SwiftUI

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
    let valueFont: Font
    let markerPlacement: MarkerPlacement
    let onBeginEditing: () -> Void
    let onEndEditing: () -> Void

    @FocusState private var isFieldFocused: Bool
    @State private var draftValue: String = ""
    @State private var isEditingValue = false

    private let accessoryWidth: CGFloat = 18

    init(
        mode: Mode,
        value: Binding<Int>,
        displaySuffix: String = "",
        readOnlySuffix: String = "",
        showsEditingSuffix: Bool = true,
        isEnabled: Bool = true,
        textFieldWidth: CGFloat = 28,
        valueFont: Font = .body.weight(.semibold),
        markerPlacement: MarkerPlacement = .inlineTrailing,
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
        self.valueFont = valueFont
        self.markerPlacement = markerPlacement
        self.onBeginEditing = onBeginEditing
        self.onEndEditing = onEndEditing
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if markerPlacement == .inlineLeading {
                accessorySlot
            }

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

                suffixView(isEditing: true)
            } else {
                displayValue
            }

            if markerPlacement != .inlineLeading {
                accessorySlot
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            beginEditingIfEnabled()
        }
        .onAppear {
            syncDraft()
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
    }

    @ViewBuilder
    private var accessorySlot: some View {
        Group {
            if isEditingValue {
                Button {
                    finishEditing()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            } else if isEnabled && markerPlacement != .hidden {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            } else {
                Color.clear
            }
        }
        .frame(width: accessoryWidth, alignment: .center)
    }

    private var displayValue: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(value)")
                .font(valueFont)
                .monospacedDigit()

            suffixView(isEditing: false)
        }
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
        guard isEnabled else { return }
        syncDraft()
        withAnimation(.easeInOut(duration: 0.18)) {
            isEditingValue = true
        }
        onBeginEditing()
        DispatchQueue.main.async {
            isFieldFocused = true
        }
    }

    private func finishEditing() {
        applyDraft(draftValue)
        syncDraft()
        withAnimation(.easeInOut(duration: 0.18)) {
            isEditingValue = false
        }
        isFieldFocused = false
        onEndEditing()
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
}
