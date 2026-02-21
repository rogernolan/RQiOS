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
            HStack(alignment: .top) {
                Text("Name")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                Text(character?.name ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                Text("Worships")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                Text(character?.worships ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("STR")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.str ?? 0)")
                            .font(.body)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("INT")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.int ?? 0)")
                            .font(.body)
                    }
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CON")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.con ?? 0)")
                            .font(.body)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("POW")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Text("\(character?.pow ?? 0)")
                                .font(.body)
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .font(.body)
                                .padding(.leading, 4)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DEX")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.dex ?? 0)")
                            .font(.body)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CHA")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(character?.cha ?? 0)")
                            .font(.body)
                    }
                }
            }
            
            HStack(alignment: .top) {
                Text("Reputation")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                Text(character?.reputation ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                Text("Occupation")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                Text(character?.occupation ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                Text("SoL")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                Text(character?.sol ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                HStack(spacing: 4) {
                    Text("Income")
                        .font(.headline)
                    Text("\(character?.income ?? 0) L")
                        .font(.body)
                }
                .frame(minWidth: 0, maxWidth: .none, alignment: .leading)
                
                Spacer()
                    .frame(width: 24)
                
                HStack(spacing: 4) {
                    Text("Ransom")
                        .font(.headline)
                    Text("\(character?.ransom ?? 0) L")
                        .font(.body)
                }
                .frame(minWidth: 0, maxWidth: .none, alignment: .leading)
            }
            Spacer()
        }
        .padding(16)
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

