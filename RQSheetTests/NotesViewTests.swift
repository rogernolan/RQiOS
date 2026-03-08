import Foundation
import Testing
@testable import RQSheet

struct NotesViewTests {
    @Test
    func contentViewAddsNotesAsTheLastTopLevelTabUsingTruthRune() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/ContentView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)
        let equipmentLabel = "tabLabel(\"Equipment\", image: \"RuneTrade\")"
        let notesLabel = "tabLabel(\"Notes\", image: \"RuneTruth\")"

        #expect(source.contains(notesLabel))
        #expect(source.contains("NotesView()"))

        let equipmentRange = try #require(source.range(of: equipmentLabel))
        let notesRange = try #require(source.range(of: notesLabel))
        let lastTabRange = try #require(source.range(of: "Tab {", options: .backwards))
        let lastNotesViewRange = try #require(source.range(of: "NotesView()", options: .backwards))

        #expect(equipmentRange.lowerBound < notesRange.lowerBound)
        #expect(lastTabRange.lowerBound < lastNotesViewRange.lowerBound)
        #expect(lastNotesViewRange.lowerBound < notesRange.lowerBound)
    }

    @Test
    func contentViewUsesResizedTabIconsRatherThanRawAssetTabs() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/ContentView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("import UIKit"))
        #expect(source.contains("tabLabel(\"Notes\", image: \"RuneTruth\")"))
        #expect(source.contains("private func resizedTabIcon(named name: String, size: CGSize = CGSize(width: 22, height: 22))"))
        #expect(source.contains("Image(uiImage: uiImage)"))
        #expect(source.contains("UIGraphicsImageRenderer"))
        #expect(source.contains("Tab {"))
    }

    @Test
    func notesViewUsesInlineHeaderPlaceholderAndSingleTranslucentSection() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/NotesView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("NavigationStack {") == false)
        #expect(source.contains("Text(\"Notes\")"))
        #expect(source.contains(".font(.title2)"))
        #expect(source.contains(".bold()"))
        #expect(source.contains("Text(\"Add notes\")"))
        #expect(source.contains("character.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty"))
        #expect(source.contains("TextEditor(text: $character.notes)"))
        #expect(source.contains(".scrollContentBackground(.hidden)"))
        #expect(source.contains(".background(Color.clear)"))
        #expect(source.contains(".background(Color(.systemBackground).opacity(0.52), in: RoundedRectangle(cornerRadius: 16))"))
        #expect(source.contains(".background(.ultraThinMaterial, in: .rect(cornerRadius: 16))") == false)
    }
}
