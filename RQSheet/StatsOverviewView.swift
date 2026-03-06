//
//  StatsOverviewView.swift
//  RQSheet
//

import PhotosUI
import SwiftData
import SwiftUI

struct StatsOverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var characters: [RQCharacter]

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isPresentingPassionEditor = false

    private var character: RQCharacter? {
        characters.first
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                headerRow

                if character == nil {
                    Button("Create New Character") {
                        _ = SkillSeeder.createCharacter(in: modelContext)
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let character {
                    summaryContent(for: character)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .mainRuneBackground(runeName: "RuneMan")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isPresentingPassionEditor) {
                if let character {
                    SummaryPassionEditorSheet { description, percentage in
                        character.addPassion(description: description, percentage: percentage)
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem, let character else { return }

                Task { @MainActor in
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        character.portraitData = data
                    }
                    selectedPhotoItem = nil
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(summaryTitle)
                .font(.title2)
                .bold()

            Spacer()

            if let character {
                NavigationLink {
                    CharacterEditorView(character: character)
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.headline)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit character details")
            }
        }
    }

    private func summaryContent(for character: RQCharacter) -> some View {
        let viewModel = SummaryViewModel(character: character)

        return ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                identityCard(character: character, viewModel: viewModel)
                topRunesCard(viewModel: viewModel)
                derivedStatsCard(viewModel: viewModel)
                honorCard(character: character)
                passionsCard(character: character)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func identityCard(character: RQCharacter, viewModel: SummaryViewModel) -> some View {
        SummaryCard(title: "Identity", headerAction: {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("Change Photo", systemImage: "photo")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Change portrait")
        }) {
            HStack(alignment: .top, spacing: 12) {
                SummaryPortraitView(portraitData: character.portraitData)

                VStack(alignment: .leading, spacing: 8) {
                    SummaryValueRow(label: "Name", value: viewModel.displayName)
                    SummaryValueRow(label: "Date of Birth", value: viewModel.dateOfBirthText)
                    SummaryValueRow(label: "Family", value: viewModel.familyText)
                    SummaryValueRow(label: "Patron", value: viewModel.patronText)
                }
            }
        }
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

    private func derivedStatsCard(viewModel: SummaryViewModel) -> some View {
        SummaryCard(title: "Derived Stats") {
            HStack(spacing: 8) {
                DerivedStatChip(label: "HP", value: viewModel.hitPointsText)
                DerivedStatChip(label: "Healing", value: viewModel.healingRateText)
                DerivedStatChip(label: "Move", value: viewModel.moveText)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                ForEach(viewModel.groupBonuses, id: \.name) { bonus in
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
        let honor = character.ensureHonorExists()

        return SummaryCard(title: "Honor") {
            HStack(alignment: .center, spacing: 8) {
                Text(honor.descriptionText.isEmpty ? "Honor" : honor.descriptionText)
                Spacer()
                Text("\(honor.percentage)%")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Button {
                    honor.experienceCheck.toggle()
                } label: {
                    Image(systemName: honor.experienceCheck ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle Honor experience check")
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
                Label("Add Passion", systemImage: "plus")
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

    private var summaryTitle: String {
        guard let character else { return "Summary" }
        return character.name.isEmpty ? "Summary" : character.name
    }

    private func formattedBonus(_ value: Int) -> String {
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(value)%"
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
        .background(.regularMaterial, in: .rect(cornerRadius: 10))
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

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.quaternary, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 10))
    }
}
