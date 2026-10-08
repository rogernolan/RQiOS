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
        let isRunningUnderTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let launchArguments = ProcessInfo.processInfo.arguments
        let schema = Schema([
            RQCharacter.self,
            CharacterEquipmentItem.self,
            CharacterSpell.self,
            RuneAffinity.self,
            SkillDefinition.self,
            CharacterSkill.self,
            Weapon.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
            CharacterEquipmentItem.self,
        ])
        let usesInMemoryStore = isRunningUnderTests || launchArguments.contains("-ui-testing-in-memory")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: usesInMemoryStore)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            if launchArguments.contains("-ui-testing-seed-combat-weapons") {
                seedCombatWeaponsIfNeeded(in: container)
            }
            return container
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

    private static func seedCombatWeaponsIfNeeded(in container: ModelContainer) {
        let context = container.mainContext
        let descriptor = FetchDescriptor<RQCharacter>()

        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        let character = RQCharacter(name: "UI Test Character")
        character.weapons = (1...12).map { index in
            let weapon = Weapon(
                character: character,
                name: "Weapon \(index)",
                basePercentage: index * 5,
                experienceCheck: index.isMultiple(of: 2),
                damage: index.isMultiple(of: 3) ? "1d8" : "1d6+1",
                hpMax: 6,
                hpCurrent: 6,
                enc: max(0, index % 3),
                strikeRank: index.isMultiple(of: 4) ? "2/8" : "\(max(1, index % 8))",
                type: index.isMultiple(of: 2) ? .slashing : .impaling,
                range: index.isMultiple(of: 3) ? "20m" : "",
                isEquipped: index <= 2
            )
            return weapon
        }

        context.insert(character)
        try? context.save()
    }
}
