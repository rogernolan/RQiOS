//
//  StatsOverviewView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

struct StatsOverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var characters: [RQCharacter]

    var character: RQCharacter? {
        characters.first
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Text(summaryTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    if let character = character {
                        NavigationLink {
                            CharacterEditorView(character: character)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.headline)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Edit Character details")
                    }
                }

                if character == nil {
                    Button("Create New Character") {
                        _ = SkillSeeder.createCharacter(in: modelContext)
                    }
                }

                if let character = character {
                    SummaryReadOnlyView(character: character)
                }

                Spacer()
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var summaryTitle: String {
        guard let character else { return "Summary" }
        return character.name.isEmpty ? "Summary" : character.name
    }
}

private struct SummaryReadOnlyView: View {
    @Bindable var character: RQCharacter

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            summaryRow("Worships", display(character.worships))

            HStack(spacing: 16) {
                statValue("STR", character.str)
                statValue("CON", character.con)
                statValue("SIZ", character.siz)
                statValue("DEX", character.dex)
                statValue("INT", character.int)
                powStatValue
                statValue("CHA", character.cha)
            }

            summaryRow("Reputation", "\(character.reputation)")
            summaryRow("Occupation", display(character.occupation))
            summaryRow("SoL", display(character.sol))
            summaryRow("Income", "\(character.income) L")
            summaryRow("Ransom", "\(character.ransom) L")
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func statValue(_ label: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.body)
        }
    }

    private var powStatValue: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text("POW")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button {
                    character.powExperienceCheck.toggle()
                } label: {
                    Image(systemName: character.powExperienceCheck ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle POW experience check")
            }
            Text("\(character.pow)")
                .font(.body)
        }
    }

    private func display(_ value: String) -> String {
        value.isEmpty ? "-" : value
    }
}
