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

        #expect(source.contains("DerivedStatChip(label: \"MP\""))
        #expect(source.contains("DerivedStatChip(label: \"RP\""))
        #expect(source.contains("SummaryCard(title: \"Skill Bonuses\")"))
    }
}
