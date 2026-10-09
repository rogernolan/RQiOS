import Foundation
import Testing
@testable import RQSheet

struct CharacterWorkspaceShellTests {
    @Test
    func contentViewUsesCharacterListNavigationShell() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "RQSheet/ContentView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("NavigationStack"))
        #expect(source.contains("navigationPath.removeAll"))
        #expect(source.contains("CharacterListView { character in"))
        #expect(source.contains("CharacterWorkspaceView(character: character)"))
        #expect(source.contains("navigationPath = [replacement]"))
    }
}
