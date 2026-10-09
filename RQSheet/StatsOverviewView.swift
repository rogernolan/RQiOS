//
//  StatsOverviewView.swift
//  RQSheet
//

import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct StatsOverviewView: View {
    @Environment(\.characterSectionPresentation) private var presentation
    private struct SummaryProfileLayoutMetrics {
        let cardWidth: CGFloat
        let sectionHeight: CGFloat
        let profileContentPadding: CGFloat
        let portraitSize: CGFloat
        let portraitCornerRadius: CGFloat
        let portraitFallbackPadding: CGFloat
        let metadataTop: CGFloat
        let metadataLeading: CGFloat
        let metadataWidth: CGFloat
    }

    let character: RQCharacter

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isPresentingPassionEditor = false
    @State private var summaryScrollOffset: CGFloat = 0

    private let summaryProfileCollapseDistance: CGFloat = 140

    var body: some View {
        Group {
            if presentation.isTile {
                tileSummaryContent
            } else {
                summaryContent(for: character)
            }
        }
            .sectionRuneBackground(runeName: "RuneMan")
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }

                Task { @MainActor in
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        character.portraitData = data
                    }
                    selectedPhotoItem = nil
                }
            }
            .sheet(isPresented: $isPresentingPassionEditor) {
                SummaryPassionEditorSheet { description, percentage in
                    character.addPassion(description: description, percentage: percentage)
                }
            }
    }

    private var tileSummaryContent: some View {
        let viewModel = SummaryViewModel(character: character)
        return VStack(alignment: .leading, spacing: 12) {
            tabletProfile(viewModel: viewModel, availableWidth: presentation.tileWidth ?? 360)
            characteristicsCard(character: character, viewModel: viewModel)
            derivedStatsCard(viewModel: viewModel)
            honorCard(character: character)
            passionsCard(character: character)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tabletProfile(viewModel: SummaryViewModel, availableWidth: CGFloat) -> some View {
        let layout = IPadSummaryProfileLayout(availableWidth: availableWidth)
        let container = layout.usesHorizontalLayout
            ? AnyLayout(HStackLayout(alignment: .center, spacing: 20))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: 12))

        return container {
            SummaryPortraitView(
                portraitData: character.portraitData,
                width: layout.portraitSize,
                height: layout.portraitSize,
                cornerRadius: 16,
                fallbackPadding: 18
            )
            .overlay(alignment: .topTrailing) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "camera.fill")
                        .font(.footnote)
                        .padding(8)
                        .background(.thinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Change portrait")
                .padding(8)
            }

            VStack(alignment: .leading, spacing: 12) {
                SummaryValueRow(label: "Family", value: viewModel.familyText)
                SummaryValueRow(label: "Patron", value: viewModel.patronText)
                SummaryValueRow(label: "Date of Birth", value: viewModel.dateOfBirthText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.52), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("summary.ipadProfile")
    }

    private func summaryContent(for character: RQCharacter) -> some View {
        let viewModel = SummaryViewModel(character: character)
        let profileCollapseProgress = profileCollapseProgress(for: summaryScrollOffset)
        let profileReleaseOffset = profileReleaseOffset(for: summaryScrollOffset)

        return GeometryReader { geometry in
            let contentWidth = geometry.size.width - 32
            let profileTopOffset: CGFloat = 16
            let profileLayout = summaryProfileLayoutMetrics(availableWidth: contentWidth, collapseProgress: profileCollapseProgress)
            let effectiveProfileSpacerHeight = profileTopOffset + profileLayout.sectionHeight + min(summaryScrollOffset, summaryProfileCollapseDistance)

            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Color.clear
                            .frame(height: effectiveProfileSpacerHeight)
                        characteristicsCard(character: character, viewModel: viewModel)
                        derivedStatsCard(viewModel: viewModel)
                        honorCard(character: character)
                        passionsCard(character: character)
                        topRunesCard(viewModel: viewModel)
                        skillBonusesCard(viewModel: viewModel)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                } action: { _, newOffset in
                    summaryScrollOffset = max(newOffset, 0)
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea(edges: .bottom)

                summaryProfileSection(
                    character: character,
                    viewModel: viewModel,
                    availableWidth: contentWidth,
                    collapseProgress: profileCollapseProgress
                )
                .frame(width: contentWidth, alignment: .leading)
                .allowsHitTesting(false)
                .offset(x: 16, y: profileTopOffset - profileReleaseOffset)

                summaryProfileCameraButton(
                    availableWidth: contentWidth,
                    collapseProgress: profileCollapseProgress
                )
                .frame(width: contentWidth, alignment: .leading)
                .offset(x: 16, y: profileTopOffset - profileReleaseOffset)
            }
        }
    }

    private func profileCollapseProgress(for offset: CGFloat) -> CGFloat {
        return min(max(offset / summaryProfileCollapseDistance, 0), 1)
    }

    private func profileReleaseOffset(for offset: CGFloat) -> CGFloat {
        return max(offset - summaryProfileCollapseDistance, 0)
    }

    private func easeInOut(_ value: CGFloat) -> CGFloat {
        return value * value * (3 - (2 * value))
    }

    private func profileSectionHeight(for width: CGFloat, collapseProgress: CGFloat) -> CGFloat {
        let expandedPortraitInset: CGFloat = 4
        let collapsedPortraitSize: CGFloat = 96
        let metadataHeight: CGFloat = 84
        let portraitMetadataSpacing: CGFloat = 12
        let collapsedCardPadding: CGFloat = 14
        let expandedPortraitSize = width - (expandedPortraitInset * 2)
        let expandedHeight = expandedPortraitInset + expandedPortraitSize + portraitMetadataSpacing + metadataHeight + collapsedCardPadding
        let collapsedHeight = collapsedPortraitSize + (collapsedCardPadding * 2)

        return expandedHeight - ((expandedHeight - collapsedHeight) * collapseProgress)
    }

    private func summaryProfileLayoutMetrics(availableWidth: CGFloat, collapseProgress: CGFloat) -> SummaryProfileLayoutMetrics {
        let cardWidth = max(availableWidth, 124)
        let cardCornerRadius: CGFloat = 12
        let expandedPortraitInset: CGFloat = 4
        let collapsedPortraitSize: CGFloat = 96
        let collapsedCardPadding: CGFloat = 14
        let expandedPortraitSize = cardWidth - (expandedPortraitInset * 2)
        let expandedPortraitCornerRadius = cardCornerRadius - expandedPortraitInset
        let collapsedPortraitCornerRadius: CGFloat = 20
        let portraitMetadataSpacing: CGFloat = 12
        let profileContentPadding = expandedPortraitInset + ((collapsedCardPadding - expandedPortraitInset) * collapseProgress)
        let portraitSize = expandedPortraitSize - ((expandedPortraitSize - collapsedPortraitSize) * collapseProgress)
        let portraitCornerRadius = expandedPortraitCornerRadius + ((collapsedPortraitCornerRadius - expandedPortraitCornerRadius) * collapseProgress)
        let portraitFallbackPadding = 18 - (6 * collapseProgress)
        let expandedMetadataTop = profileContentPadding + portraitSize + portraitMetadataSpacing
        let collapsedMetadataTop = collapsedCardPadding
        let metadataVerticalProgress = easeInOut(min(pow(collapseProgress, 1.85), 1))
        let metadataTop = expandedMetadataTop + ((collapsedMetadataTop - expandedMetadataTop) * metadataVerticalProgress)
        let expandedMetadataLeading = collapsedCardPadding
        let collapsedMetadataLeading = collapsedCardPadding + collapsedPortraitSize + portraitMetadataSpacing
        let metadataHorizontalProgress = easeInOut(min(pow(collapseProgress, 0.55), 1))
        let metadataLeading = expandedMetadataLeading + ((collapsedMetadataLeading - expandedMetadataLeading) * metadataHorizontalProgress)
        let metadataWidth = max(cardWidth - metadataLeading - collapsedCardPadding, 0)
        let sectionHeight = profileSectionHeight(for: cardWidth, collapseProgress: collapseProgress)

        return SummaryProfileLayoutMetrics(
            cardWidth: cardWidth,
            sectionHeight: sectionHeight,
            profileContentPadding: profileContentPadding,
            portraitSize: portraitSize,
            portraitCornerRadius: portraitCornerRadius,
            portraitFallbackPadding: portraitFallbackPadding,
            metadataTop: metadataTop,
            metadataLeading: metadataLeading,
            metadataWidth: metadataWidth
        )
    }

    private func summaryProfileCameraButton(availableWidth: CGFloat, collapseProgress: CGFloat) -> some View {
        let layout = summaryProfileLayoutMetrics(availableWidth: availableWidth, collapseProgress: collapseProgress)

        return ZStack(alignment: .topLeading) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "camera.fill")
                    .font(.footnote)
                    .padding(6)
                    .background(.thinMaterial, in: .circle)
                    .overlay {
                        Circle()
                            .stroke(.quaternary, lineWidth: 1)
                    }
                    .padding(8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change portrait")
            .frame(width: layout.portraitSize, height: layout.portraitSize, alignment: .topTrailing)
            .offset(x: layout.profileContentPadding, y: layout.profileContentPadding)
        }
        .frame(width: layout.cardWidth, height: layout.sectionHeight, alignment: .topLeading)
    }

    private func summaryProfileSection(character: RQCharacter, viewModel: SummaryViewModel, availableWidth: CGFloat, collapseProgress: CGFloat) -> some View {
        let layout = summaryProfileLayoutMetrics(availableWidth: availableWidth, collapseProgress: collapseProgress)
        let cardCornerRadius: CGFloat = 12

        return ZStack(alignment: .topLeading) {
            SummaryPortraitView(
                portraitData: character.portraitData,
                width: layout.portraitSize,
                height: layout.portraitSize,
                cornerRadius: layout.portraitCornerRadius,
                fallbackPadding: layout.portraitFallbackPadding
            )
            .offset(x: layout.profileContentPadding, y: layout.profileContentPadding)

            VStack(alignment: .leading, spacing: 8) {
                SummaryValueRow(label: "Family", value: viewModel.familyText)
                SummaryValueRow(label: "Patron", value: viewModel.patronText)
                SummaryValueRow(label: "Date of Birth", value: viewModel.dateOfBirthText)
            }
            .frame(width: layout.metadataWidth, alignment: .leading)
            .offset(x: layout.metadataLeading, y: layout.metadataTop)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: layout.sectionHeight, alignment: .topLeading)
        .background(Color(.systemBackground).opacity(0.52), in: .rect(cornerRadius: cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: cardCornerRadius))
    }

    private func topRunesCard(viewModel: SummaryViewModel) -> some View {
        SummaryCard(title: "Top Rune Affinities") {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                spacing: 8
            ) {
                ForEach(viewModel.topRunes, id: \.name) { rune in
                    SummaryRuneTile(rune: rune)
                }
            }
        }
    }

    private func characteristicsCard(character: RQCharacter, viewModel: SummaryViewModel) -> some View {
        let columnCount = presentation.usesCompactTileContent ? 2 : 4
        let rows = chunked(viewModel.primaryStats, size: columnCount)

        return SummaryCard {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: 8) {
                        ForEach(rows[rowIndex], id: \.label) { stat in
                            CharacteristicChip(
                                label: stat.label,
                                value: stat.value,
                                isChecked: stat.label == "POW" ? character.powExperienceCheck : nil
                            ) {
                                guard stat.label == "POW" else { return }
                                character.powExperienceCheck.toggle()
                            }
                        }

                        if rows[rowIndex].count < columnCount {
                            ForEach(rows[rowIndex].count..<columnCount, id: \.self) { _ in
                                Spacer(minLength: 0)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }

    private func derivedStatsCard(viewModel: SummaryViewModel) -> some View {
        let derivedStats = [
            (label: "HP", value: viewModel.hitPointsText, hasAlertBorder: false, usesSecondaryValueStyle: false),
            (label: "Healing", value: viewModel.healingRateText, hasAlertBorder: false, usesSecondaryValueStyle: false),
            (label: "Move", value: viewModel.moveText, hasAlertBorder: false, usesSecondaryValueStyle: viewModel.isMoveFallback),
            (label: "MP", value: viewModel.magicPointsText, hasAlertBorder: false, usesSecondaryValueStyle: false),
            (label: "RP", value: viewModel.runePointsText, hasAlertBorder: false, usesSecondaryValueStyle: false),
            (label: "ENC", value: viewModel.encumbranceText, hasAlertBorder: viewModel.isEncumbranceOverLimit, usesSecondaryValueStyle: false),
        ]
        let columnCount = presentation.usesCompactTileContent ? 2 : 3
        let rows = chunked(derivedStats, size: columnCount)

        return SummaryCard(title: "Derived Stats") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: 8) {
                        ForEach(rows[rowIndex], id: \.label) { stat in
                            DerivedStatChip(
                                label: stat.label,
                                value: stat.value,
                                hasAlertBorder: stat.hasAlertBorder,
                                usesSecondaryValueStyle: stat.usesSecondaryValueStyle
                            )
                        }

                        if rows[rowIndex].count < columnCount {
                            ForEach(rows[rowIndex].count..<columnCount, id: \.self) { _ in
                                Spacer(minLength: 0)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }

    private func skillBonusesCard(viewModel: SummaryViewModel) -> some View {
        SummaryCard(title: "Skill Bonuses") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(viewModel.skillBonuses, id: \.name) { bonus in
                    HStack(alignment: .center, spacing: 8) {
                        Text(bonus.name)
                        Spacer()
                        Text(formattedBonus(bonus.value))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func honorCard(character: RQCharacter) -> some View {
        let honor = character.honor

        return SummaryCard {
            HStack(alignment: .center, spacing: 8) {
                Text("Honor")

                Spacer()
                Text("\(honor?.percentage ?? 0)")
                .monospacedDigit()

                Text("%")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func passionsCard(character: RQCharacter) -> some View {
        let sortedPassions = character.passions.sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.descriptionText < rhs.descriptionText
            }
            return lhs.sortOrder < rhs.sortOrder
        }

        return SummaryCard(title: "Passions", headerAction: {
            Button {
                isPresentingPassionEditor = true
            } label: {
                Text("+")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Add passion")
        }) {
            if sortedPassions.isEmpty {
                Text("No passions yet")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(sortedPassions) { passion in
                        HStack(alignment: .center, spacing: 8) {
                            Text(passion.descriptionText.isEmpty ? "-" : passion.descriptionText)
                            Spacer()
                            Text("\(passion.percentage)%")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func formattedBonus(_ value: Int) -> String {
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(value)%"
    }

    private func chunked<T>(_ values: [T], size: Int) -> [[T]] {
        guard size > 0 else { return [values] }
        var result: [[T]] = []
        var index = 0
        while index < values.count {
            let end = min(index + size, values.count)
            result.append(Array(values[index..<end]))
            index += size
        }
        return result
    }
}

private struct SummaryValueRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 94, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct SummaryRuneTile: View {
    let rune: SummaryRuneDisplay

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("Rune\(rune.name.rawValue)")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(rune.name.rawValue)
                    .font(.subheadline)
                    .lineLimit(1)
                Text("\(rune.percentage)%")
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 10))
        .opacity(rune.isPlaceholder ? 0.72 : 1)
        .accessibilityValue(rune.isPlaceholder ? "Placeholder affinity" : "\(rune.percentage) percent")
    }
}

private struct DerivedStatChip: View {
    let label: String
    let value: String
    var hasAlertBorder = false
    var usesSecondaryValueStyle = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .monospacedDigit()
                .foregroundStyle(usesSecondaryValueStyle ? .secondary : .primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
        .overlay {
            if hasAlertBorder {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.red, lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.quaternary, lineWidth: 1)
            }
        }
        .clipShape(.rect(cornerRadius: 10))
    }
}

private struct CharacteristicChip: View {
    let label: String
    let value: Int
    let isChecked: Bool?
    let toggleCheck: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("summary.characteristic.\(label).label")

            HStack(alignment: .center, spacing: 4) {
                Text("\(value)")
                    .font(.body)
                    .monospacedDigit()
                    .accessibilityIdentifier("summary.characteristic.\(label).value")

                Spacer(minLength: 0)

                if let isChecked {
                    Button {
                        toggleCheck()
                    } label: {
                        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Toggle POW experience check")
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 10))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("summary.characteristic.\(label)")
    }
}
