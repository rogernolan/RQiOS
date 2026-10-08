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
            let container = try AppPersistence.makeContainer(inMemory: isRunningUnderTests, diagnostics: isRunningUnderTests ? .none : .shared)
            if ProcessInfo.processInfo.arguments.contains("-ui-testing-seed-combat-weapons") {
                Self.seedCombatWeaponsIfNeeded(in: container)
            }
            sharedModelContainer = container
            startupError = nil
        } catch {
            startupError = error.localizedDescription
        }
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
