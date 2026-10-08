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
    @State private var navigationPath: [RQCharacter] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CharacterListView { character in
                navigationPath = [character]
            }
                .navigationDestination(for: RQCharacter.self) { character in
                    CharacterWorkspaceView(character: character) { replacement in
                        navigationPath = [replacement]
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(try! AppPersistence.makeContainer(inMemory: true, cloudKitEnabled: false))
}
