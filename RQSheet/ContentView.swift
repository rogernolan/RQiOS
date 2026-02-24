//
//  ContentView.swift
//  RQSheet
//
//  Created by Roger Nolan on 21/02/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            StatsOverviewView()
                .tabItem {
                    Label("Summary", systemImage: "person")
                }
            CombatView()
                .tabItem {
                    Label("Combat", systemImage: "chart.bar")
                }
            SkillsView()
                .tabItem {
                    Label("Skills", systemImage: "list.bullet")
                }
            RunesView()
                .tabItem {
                    Label("Runes", systemImage: "sparkles")
                }
            EquipmentView()
                .tabItem {
                    Label("Equipment", systemImage: "backpack")
                }
        }
    }
}

#Preview {
    ContentView().modelContainer(
        for: [RQCharacter.self, RuneAffinity.self, SkillDefinition.self, CharacterSkill.self, WeaponSkill.self],
        inMemory: true
    )
}
