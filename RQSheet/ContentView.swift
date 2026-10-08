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
                    .id(character.persistentModelID)
                }
        }
    }
}

#Preview {
    ContentView().modelContainer(
        for: [
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
        ],
        inMemory: true
    )
}
