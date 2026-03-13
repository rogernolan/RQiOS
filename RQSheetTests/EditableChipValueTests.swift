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

    private func editableChipValueSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/EditableChipValue.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
