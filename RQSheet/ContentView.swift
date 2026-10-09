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
    @Query private var characters: [RQCharacter]
    @State private var navigationPath: [PersistentIdentifier] = []

    private var visibleCharacterIDs: Set<PersistentIdentifier> {
        Set(characters.map(\.persistentModelID))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CharacterListView { character in
                navigationPath = [character.persistentModelID]
            }
                .navigationDestination(for: PersistentIdentifier.self) { characterID in
                    if let character = characters.first(where: { $0.persistentModelID == characterID }) {
                        CharacterWorkspaceView(character: character) { replacement in
                            navigationPath = [replacement.persistentModelID]
                        }
                    } else {
                        EmptyView()
                    }
                }
        }
        .onChange(of: visibleCharacterIDs) { _, visibleCharacterIDs in
            navigationPath.removeAll { !visibleCharacterIDs.contains($0) }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(try! AppPersistence.makeContainer(inMemory: true, cloudKitEnabled: false))
}
