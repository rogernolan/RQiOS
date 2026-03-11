import Foundation
import Testing
@testable import RQSheet

struct NotesViewTests {
    @Test
    func characterWorkspaceRoutesNotesThroughExplicitMoreTab() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/CharacterWorkspaceView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("Tab(value: WorkspaceTab.extras)"))
        #expect(source.contains("CharacterMoreTabView("))
        #expect(source.contains("NotesView(character: character)"))
        #expect(source.contains("case notes"))
        #expect(source.contains("case .notes:"))
        #expect(source.contains("destination.title"))
        #expect(source.contains("Button(action: onBack)"))
        #expect(source.contains("selectedExtrasDestination = destination"))
        #expect(source.contains("MorePopupMenu("))
        #expect(source.contains("RuneTruth"))
        #expect(source.contains("dismissWorkspace"))
        #expect(source.contains(".pickerStyle(.segmented)") == false)
        #expect(source.contains("Menu {") == false)
        #expect(source.contains("NavigationLink {") == false)
        #expect(source.contains(".confirmationDialog(\"More\"") == false)
    }

    @Test
    func characterWorkspaceUsesResizedTabIconsRatherThanRawAssetTabs() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/CharacterWorkspaceView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("import UIKit"))
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
        #expect(source.contains("Text(\"Notes\")") == false)
        #expect(source.contains("Text(\"Add notes\")"))
        #expect(source.contains("character.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty"))
        #expect(source.contains("TextEditor(text: $character.notes)"))
        #expect(source.contains(".scrollContentBackground(.hidden)"))
        #expect(source.contains(".background(Color.clear)"))
        #expect(source.contains(".background(Color(.systemBackground).opacity(0.52), in: RoundedRectangle(cornerRadius: 16))"))
        #expect(source.contains(".background(.ultraThinMaterial, in: .rect(cornerRadius: 16))") == false)
    }
}
