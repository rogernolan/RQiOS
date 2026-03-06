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
            StatsOverviewView()
                .tabItem {
                    tabLabel("Summary", image: "RuneMan")
                }
            CombatView()
                .tabItem {
                    tabLabel("Combat", image: "RuneDeath")
                }
            SkillsView()
                .tabItem {
                    tabLabel("Skills", image: "RuneMastery")
                }
            RunesView()
                .tabItem {
                    tabLabel("Runes", image: "RuneInfinity")
                }
            MagicView()
                .tabItem {
                    tabLabel("Magic", image: "RuneMagic")
                }
            EquipmentView()
                .tabItem {
                    tabLabel("Equipment", image: "RuneTrade")
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
            RuneAffinity.self,
            SkillDefinition.self,
            CharacterSkill.self,
            WeaponSkill.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
        ],
        inMemory: true
    )
}
