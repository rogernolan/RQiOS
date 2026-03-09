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
        #expect(source.contains("characteristicsCard(character: character, viewModel: viewModel)"))
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

    @Test
    func summaryUsesScrollDrivenProfileSectionInsteadOfStaticIdentityCard() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/StatsOverviewView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)
        let requiredSnippets = [
            "@State private var summaryScrollOffset: CGFloat = 0",
            "@State private var summaryHeaderHeight: CGFloat = 48",
            "private let summaryProfileCollapseDistance: CGFloat = 140",
            "let profileCollapseProgress = profileCollapseProgress(for: summaryScrollOffset)",
            "let profileReleaseOffset = profileReleaseOffset(for: summaryScrollOffset)",
            "GeometryReader { geometry in",
            "let contentWidth = geometry.size.width - 32",
            "let effectiveProfileSpacerHeight = profileTopOffset + profileHeight + min(summaryScrollOffset, summaryProfileCollapseDistance)",
            "Color.clear",
            ".frame(height: effectiveProfileSpacerHeight)",
            "summaryProfileSection(",
            "availableWidth: contentWidth",
            "collapseProgress: profileCollapseProgress",
            ".offset(x: 16, y: profileTopOffset - profileReleaseOffset)",
            ".onScrollGeometryChange(for: CGFloat.self)",
            "geometry.contentOffset.y + geometry.contentInsets.top",
            "private func profileCollapseProgress(for offset: CGFloat) -> CGFloat",
            "return min(max(offset / summaryProfileCollapseDistance, 0), 1)",
            "private func profileReleaseOffset(for offset: CGFloat) -> CGFloat",
            "return max(offset - summaryProfileCollapseDistance, 0)",
            "private func easeInOut(_ value: CGFloat) -> CGFloat",
            "return value * value * (3 - (2 * value))",
            "private func summaryProfileSection(character: RQCharacter, viewModel: SummaryViewModel, availableWidth: CGFloat, collapseProgress: CGFloat) -> some View",
            "let expandedPortraitInset: CGFloat = 4",
            "let expandedPortraitSize = cardWidth - (expandedPortraitInset * 2)",
            "let profileContentPadding = expandedPortraitInset + ((collapsedCardPadding - expandedPortraitInset) * collapseProgress)",
            "let expandedPortraitCornerRadius = cardCornerRadius - expandedPortraitInset",
            "let collapsedPortraitCornerRadius: CGFloat = 20",
            "let collapsedMetadataTop = collapsedCardPadding",
            "let metadataVerticalProgress = easeInOut(min(pow(collapseProgress, 1.85), 1))",
            "let collapsedMetadataLeading = collapsedCardPadding + collapsedPortraitSize + portraitMetadataSpacing",
            "let metadataHorizontalProgress = easeInOut(min(pow(collapseProgress, 0.55), 1))",
            "let metadataTop = expandedMetadataTop + ((collapsedMetadataTop - expandedMetadataTop) * metadataVerticalProgress)",
            "let metadataLeading = expandedMetadataLeading + ((collapsedMetadataLeading - expandedMetadataLeading) * metadataHorizontalProgress)"
        ]
        let forbiddenSnippets = [
            "@State private var summaryProfileWidth: CGFloat = 0",
            "identityCard(character: character, viewModel: viewModel)",
            "SummaryScrollOffsetReader()",
            "SummaryScrollOffsetPreferenceKey",
            "SummaryProfileWidthPreferenceKey"
        ]

        let missingSnippets = requiredSnippets.filter { source.contains($0) == false }
        let unexpectedSnippets = forbiddenSnippets.filter { source.contains($0) }

        #expect(missingSnippets.isEmpty)
        #expect(unexpectedSnippets.isEmpty)
    }
}
