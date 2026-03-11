import Foundation
import Testing
@testable import RQSheet

struct CharacterListViewTests {
    @Test
    func characterListShowsWorshipsAndRuneIconsWithoutPercentages() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/CharacterListView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("character.worships"))
        #expect(source.contains("Text(\"\\(rune.percentage)%\")") == false)
        #expect(source.contains("Image(\"Rune\\(rune.name.rawValue)\")"))
    }
}
