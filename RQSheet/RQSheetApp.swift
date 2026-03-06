//
//  RQSheetApp.swift
//  RQSheet
//
//  Created by Roger Nolan on 21/02/2026.
//

import SwiftUI
import SwiftData

@main
struct RQSheetApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RQCharacter.self,
            RuneAffinity.self,
            SkillDefinition.self,
            CharacterSkill.self,
            WeaponSkill.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
            CharacterEquipmentItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
