import Foundation
import Testing
@testable import RQSheet

struct StatsOverviewViewTests {
    @Test
    func summaryLayoutSeparatesDerivedStatsAndSkillBonuses() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/StatsOverviewView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("derivedStatsCard(viewModel: viewModel)"))
        #expect(source.contains("skillBonusesCard(viewModel: viewModel)"))
        #expect(source.contains("characteristicsCard(character: character, viewModel: viewModel)\n                derivedStatsCard(viewModel: viewModel)"))
    }

    @Test
    func derivedStatsCardIncludesMagicAndRunePointChips() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/StatsOverviewView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("(label: \"MP\", value: viewModel.magicPointsText, hasAlertBorder: false)"))
        #expect(source.contains("(label: \"RP\", value: viewModel.runePointsText, hasAlertBorder: false)"))
        #expect(source.contains("SummaryCard(title: \"Skill Bonuses\")"))
    }

    @Test
    func derivedStatsUseTwoRowsOfThreeAndCharacteristicChipStyling() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/StatsOverviewView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("let rows = chunked(derivedStats, size: 3)"))
        #expect(source.contains("ForEach(rows.indices, id: \\.self)"))
        #expect(source.contains(".background(Color(.systemBackground), in: .rect(cornerRadius: 10))"))
        #expect(source.contains(".background(.regularMaterial, in: .rect(cornerRadius: 10))") == false)
    }
}
