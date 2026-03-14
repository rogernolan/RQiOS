import Foundation
import Testing
@testable import RQSheet

struct EditableChipValueTests {
    @Test
    func sharedEditableChipValueSupportsSingleAndCurrentOfMaxModes() throws {
        let source = try editableChipValueSource()

        #expect(source.contains("struct EditableChipValue: View"))
        #expect(source.contains("enum Mode"))
        #expect(source.contains("case singleValue"))
        #expect(source.contains("case currentOfMax"))
    }

    @Test
    func sharedEditableChipValueIncludesEditableMarkerAndCompletionControl() throws {
        let source = try editableChipValueSource()

        #expect(source.contains("square.and.pencil"))
        #expect(source.contains("checkmark.circle.fill"))
        #expect(source.contains(".green"))
        #expect(source.contains("withAnimation"))
        #expect(source.contains(".overlay(alignment: .topTrailing)") == false)
    }

    @Test
    func sharedEditableChipValueSupportsHeaderMarkerAndHiddenEditingSuffix() throws {
        let source = try editableChipValueSource()

        #expect(source.contains("let markerPlacement: MarkerPlacement"))
        #expect(source.contains("enum MarkerPlacement"))
        #expect(source.contains("case inlineLeading"))
        #expect(source.contains("case inlineTrailing"))
        #expect(source.contains("showsEditingSuffix"))
    }

    @Test
    func sharedEditableChipValueAnimatesCompletionButtonAndValueShift() throws {
        let source = try editableChipValueSource()

        #expect(source.contains("private let completionButtonStartScale: CGFloat = 0.25"))
        #expect(source.contains("private let completionButtonOvershootScale: CGFloat = 1.1"))
        #expect(source.contains("private let completionButtonRestScale: CGFloat = 1"))
        #expect(source.contains("private let completionButtonStartOpacity: Double = 0.25"))
        #expect(source.contains("@State private var completionButtonScale"))
        #expect(source.contains("@State private var completionButtonOpacity"))
        #expect(source.contains("@State private var valueContentOffset: CGFloat = 0"))
        #expect(source.contains("withAnimation(.spring"))
        #expect(source.contains("valueContentOffset ="))
    }

    @Test
    func sharedEditableChipValueHasDedicatedCompletionPathToAvoidRetapRescroll() throws {
        let source = try editableChipValueSource()

        #expect(source.contains("private func completeEditingFromButton()"))
        #expect(source.contains("completeEditingFromButton()"))
        #expect(source.contains("Button {\n                    completeEditingFromButton()"))
        #expect(source.contains(".onTapGesture {\n                    beginEditingIfEnabled()\n                }"))
        #expect(source.contains(".contentShape(Rectangle())\n        .onTapGesture") == false)
    }

    @Test
    func sharedEditableChipValueSupportsExternalChipActivationAndConfigurableTravel() throws {
        let source = try editableChipValueSource()

        #expect(source.contains("final class EditableChipValueController: ObservableObject"))
        #expect(source.contains("@ObservedObject var controller: EditableChipValueController"))
        #expect(source.contains("func requestBeginEditing()"))
        #expect(source.contains("onChange(of: controller.activationID)"))
        #expect(source.contains("completionButtonTravel: CGFloat = 14"))
    }

    @Test
    func sharedEditableChipValueUsesTheSameVerticalTrackForDisplayAndEditing() throws {
        let source = try editableChipValueSource()

        #expect(source.contains("HStack(alignment: .center, spacing: 4)"))
        #expect(source.contains("private var editableValueContent: some View {\n        HStack(alignment: .firstTextBaseline, spacing: 2)"))
        #expect(source.contains("suffixView(isEditing: isEditingValue)"))
        #expect(source.contains("private var displayValue: some View {\n        Text(\"\\\\(value)\")"))
    }

    private func editableChipValueSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/EditableChipValue.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
