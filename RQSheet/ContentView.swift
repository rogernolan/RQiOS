//
//  ContentView.swift
//  RQSheet
//
//  Created by Roger Nolan on 21/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    var body: some View {
        TabView {
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "person")
                }
            AttributesView()
                .tabItem {
                    Label("Attributes", systemImage: "chart.bar")
                }
            SkillsView()
                .tabItem {
                    Label("Skills", systemImage: "list.bullet")
                }
            EquipmentView()
                .tabItem {
                    Label("Equipment", systemImage: "backpack")
                }
        }
    }
}

struct SummaryView: View {
    @Query private var characters: [RQCharacter]
    
    var character: RQCharacter? {
        characters.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                Text("Name")
                    .font(.headline)
                Text(character?.name ?? "—")
            }
            Group {
                Text("Worships")
                    .font(.headline)
                Text(character?.worships ?? "—")
            }
            Group {
                Text("Attributes")
                    .font(.headline)
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("STR")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.str ?? 0)")
                    }
                    VStack(alignment: .leading) {
                        Text("CON")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.con ?? 0)")
                    }
                    VStack(alignment: .leading) {
                        Text("DEX")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.dex ?? 0)")
                    }
                    VStack(alignment: .leading) {
                        Text("INT")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.int ?? 0)")
                    }
                    VStack(alignment: .leading) {
                        Text("POW")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.pow ?? 0)")
                    }
                    VStack(alignment: .leading) {
                        Text("CHA")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.cha ?? 0)")
                    }
                }
            }
            Group {
                Text("Reputation")
                    .font(.headline)
                Text(character?.reputation ?? "—")
            }
            Group {
                Text("Occupation")
                    .font(.headline)
                Text(character?.occupation ?? "—")
            }
            Group {
                Text("SoL")
                    .font(.headline)
                Text(character?.sol ?? "—")
            }
            Group {
                Text("Income")
                    .font(.headline)
                Text("\(character?.income ?? 0)")
            }
            Group {
                Text("Ransom")
                    .font(.headline)
                Text("\(character?.ransom ?? 0)")
            }
            Spacer()
        }
        .padding()
    }
}

struct AttributesView: View {
    var body: some View {
        Text("Attributes pane")
    }
}

struct SkillsView: View {
    var body: some View {
        Text("Skills pane")
    }
}

struct EquipmentView: View {
    var body: some View {
        Text("Equipment pane")
    }
}

#Preview {
    ContentView().modelContainer(for: RQCharacter.self, inMemory: true)
}
