import Foundation
import Testing
@testable import RQSheet

struct CharacterWorkspaceChromeTests {
    @Test
    func workspaceOwnsNavigationChromeAndUsesExplicitMoreTabForExtras() throws {
        let source = try workspaceSource()

        #expect(source.contains("enum WorkspaceTab"))
        #expect(source.contains("enum ExtrasDestination"))
        #expect(source.contains("@State private var selectedTab"))
        #expect(source.contains("@State private var selectedExtrasDestination: ExtrasDestination?"))
        #expect(source.contains("@State private var isShowingExtrasMenu = false"))
        #expect(source.contains("@State private var lastMainTab: WorkspaceTab = .summary"))
        #expect(source.contains("private var tabSelection: Binding<WorkspaceTab>"))
        #expect(source.contains("ToolbarItem(placement: .principal)"))
        #expect(source.contains("CharacterEditorView(character: character)"))
        #expect(source.contains("Image(systemName: \"square.and.pencil\")"))
        #expect(source.contains("Tab(value: WorkspaceTab.extras)"))
        #expect(source.contains("Label(\"More\", systemImage: \"ellipsis.circle\")"))
        #expect(source.contains("CharacterMoreTabView("))
        #expect(source.contains("MoreTabProxyButton("))
        #expect(source.contains("MorePopupMenu("))
        #expect(source.contains("MorePopupBubbleShape()"))
        #expect(source.contains("case settings"))
        #expect(source.contains("return \"Settings\""))
        #expect(source.contains("return \"RuneDisorder\""))
        #expect(source.contains("case .settings:"))
        #expect(source.contains("SettingsView(character: character)"))
        #expect(source.contains("notchInsetFromTrailingEdge: max(28, (geometry.size.width / 10) + 18)"))
        #expect(source.contains("let notchInsetFromTrailingEdge: CGFloat"))
        #expect(source.contains("let safeNotchCenterX = min("))
        #expect(source.contains(".padding(.bottom, 18)"))
        #expect(source.contains("selectedExtrasDestination = destination"))
        #expect(source.contains("selectedTab = .extras"))
        #expect(source.contains("isShowingExtrasMenu = true"))
        #expect(source.contains("dismissWorkspace()"))
        #expect(source.contains("WorkspaceInlineHeader("))
        #expect(source.contains(".padding(.bottom, 58)"))
        #expect(source.contains("Tab(value: WorkspaceTab.magic)") == false)
        #expect(source.contains("Tab(value: WorkspaceTab.equipment)") == false)
        #expect(source.contains("Tab(value: WorkspaceTab.notes)") == false)
        #expect(source.contains("NavigationStack {") == false)
        #expect(source.contains("NavigationLink {") == false)
        #expect(source.contains(".confirmationDialog(\"More\"") == false)
        #expect(source.contains(".overlay(alignment: .bottomTrailing)") == false)
        #expect(source.contains(".pickerStyle(.segmented)") == false)
    }

    @Test
    func workspaceRoutesSettingsDestinationToTextImporterShell() throws {
        let workspaceSource = try workspaceSource()
        let settingsSource = try settingsSource()
        let textImportSource = try textImportSource()

        #expect(workspaceSource.contains("SettingsView(character: character)"))
        #expect(settingsSource.contains("struct SettingsView: View"))
        #expect(settingsSource.contains("TextImportView(character: character)"))
        #expect(settingsSource.contains("Text(\"Settings\")"))
        #expect(settingsSource.contains("Text(\"Import Character\")"))
        #expect(textImportSource.contains("struct TextImportView: View"))
        #expect(textImportSource.contains("@State private var rawText = \"\""))
        #expect(textImportSource.contains("TextEditor(text: $rawText)"))
        #expect(textImportSource.contains("Button(\"Import\")"))
    }

    @Test
    func workspaceUsesNewCharacterPlaceholderTitleAndRuneAffinitiesLabel() throws {
        let source = try workspaceSource()

        #expect(source.contains("Text(currentTitle)"))
        #expect(source.contains("\"New character\""))
        #expect(source.contains("\"Rune affinities\""))
    }

    private func workspaceSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/CharacterWorkspaceView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }

    private func settingsSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/SettingsView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }

    private func textImportSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/TextImportView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
