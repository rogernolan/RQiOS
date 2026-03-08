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
            Tab {
                StatsOverviewView()
            } label: {
                tabLabel("Summary", image: "RuneMan")
            }
            Tab {
                CombatView()
            } label: {
                tabLabel("Combat", image: "RuneDeath")
            }
            Tab {
                SkillsView()
            } label: {
                tabLabel("Skills", image: "RuneMastery")
            }
            Tab {
                RunesView()
            } label: {
                tabLabel("Runes", image: "RuneInfinity")
            }
            Tab {
                MagicView()
            } label: {
                tabLabel("Magic", image: "RuneMagic")
            }
            Tab {
                EquipmentView()
            } label: {
                tabLabel("Equipment", image: "RuneTrade")
            }
            Tab {
                NotesView()
            } label: {
                tabLabel("Notes", image: "RuneTruth")
            }
        }
    }

    @ViewBuilder
    private func tabLabel(_ title: String, image: String) -> some View {
        if let uiImage = resizedTabIcon(named: image) {
            Label {
                Text(title)
            } icon: {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
            }
        } else {
            Label(title, systemImage: "circle")
        }
    }

    private func resizedTabIcon(named name: String, size: CGSize = CGSize(width: 22, height: 22)) -> UIImage? {
        guard let original = UIImage(named: name) else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { _ in
            original.draw(in: CGRect(origin: .zero, size: size))
        }
        return image.withRenderingMode(.alwaysTemplate)
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
            WeaponSkill.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
            CharacterEquipmentItem.self,
        ],
        inMemory: true
    )
}
