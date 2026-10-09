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
    @State private var sharedModelContainer: ModelContainer?
    @State private var startupError: String?
    private let eventMonitor: CloudSyncEventMonitor

    init() {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            || ProcessInfo.processInfo.arguments.contains("-ui-testing")
            || ProcessInfo.processInfo.environment["RQ_SHEET_UI_TESTING"] == "1"
        eventMonitor = CloudSyncEventMonitor(diagnostics: isTesting ? .none : .shared)
        if !isTesting { eventMonitor.start() }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let sharedModelContainer {
                    ContentView().modelContainer(sharedModelContainer)
                } else if let startupError {
                    VStack(spacing: 16) {
                        Text("Unable to Open Characters").font(.title2)
                        Text("Your stored records and available recovery evidence have been preserved.")
                        Text(startupError).font(.caption)
                        Button("Retry", action: openStore)
                    }.padding()
                } else {
                    ProgressView("Opening characters…")
                }
            }
            .task { if sharedModelContainer == nil && startupError == nil { openStore() } }
        }
    }

    private func openStore() {
        do {
            let isRunningUnderTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
                || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
                || ProcessInfo.processInfo.arguments.contains("-ui-testing")
                || ProcessInfo.processInfo.environment["RQ_SHEET_UI_TESTING"] == "1"
            let container = try AppPersistence.makeContainer(inMemory: isRunningUnderTests, diagnostics: isRunningUnderTests ? .none : .shared)
            if ProcessInfo.processInfo.arguments.contains("-ui-testing-seed-tiles") {
                Self.seedTilesIfNeeded(in: container)
            }
            if ProcessInfo.processInfo.arguments.contains("-ui-testing-seed-combat-weapons") {
                Self.seedCombatWeaponsIfNeeded(in: container)
            }
            sharedModelContainer = container
            startupError = nil
        } catch {
            startupError = error.localizedDescription
        }
    }

    private static func seedTilesIfNeeded(in container: ModelContainer) {
        let context = container.mainContext
        guard (try? context.fetchCount(FetchDescriptor<RQCharacter>())) == 0 else { return }
        let character = RQCharacter(name: "Tile Test Character", worships: "Lhankor Mhy", notes: "A journey through Nochet.\nKeep the character's notes together.")
        context.insert(character)
        let counts: [(SkillGroup, Int)] = [(.agility, 9), (.communication, 19), (.knowledge, 39), (.manipulation, 6), (.magic, 4), (.perception, 6), (.stealth, 3)]
        for (group, count) in counts {
            for index in 1...count {
                character.addSkill(name: "\(group.rawValue.capitalized) skill \(String(format: "%02d", index))", percentage: 40 + index, group: group)
            }
        }
        for index in 1...8 {
            character.weapons.append(Weapon(character: character, name: "Weapon \(index)", basePercentage: 50, damage: "1d6+1", hpMax: 8, hpCurrent: 8, enc: 1, strikeRank: "2", type: .impaling, isEquipped: index == 1))
            character.addEquipmentItem(name: "Equipment \(index)", encumbrance: 1, isCurrentlyEquipped: index == 1)
        }
        for index in 1...6 {
            character.addSpell(name: "Spirit spell \(index)", points: 1, page: "250", kind: .spiritMagic)
            character.addSpell(name: "Rune spell \(index)", points: 2, page: "320", kind: .runeSpell)
        }
        character.addPassion(description: "Loyalty (Nochet)", percentage: 65)
        try? context.save()
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
