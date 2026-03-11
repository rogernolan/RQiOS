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
        NavigationStack {
            CharacterListView()
                .navigationDestination(for: RQCharacter.self) { character in
                    CharacterWorkspaceView(character: character)
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
