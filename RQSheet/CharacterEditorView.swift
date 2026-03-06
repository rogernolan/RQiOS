//
//  CharacterEditorView.swift
//  RQSheet
//

import SwiftUI

struct CharacterEditorView: View {
    @State private var viewModel: CharacterEditorViewModel

    init(character: RQCharacter) {
        _viewModel = State(initialValue: CharacterEditorViewModel(character: character))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.availableSections, id: \.self) { section in
                    EditorSectionContainer(
                        title: title(for: section),
                        isExpanded: viewModel.expandedSections.contains(section)
                    ) {
                        viewModel.toggle(section)
                    } content: {
                        sectionContent(for: section)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func sectionContent(for section: EditorSection) -> some View {
        switch section {
        case .identity:
            EditorIdentitySectionView(viewModel: viewModel)
        case .characteristics:
            EditorCharacteristicsSectionView(viewModel: viewModel)
        case .combatAndDerived:
            EditorCombatAndDerivedSectionView(viewModel: viewModel)
        case .social:
            EditorSocialSectionView(viewModel: viewModel)
        case .economy:
            EditorEconomySectionView(viewModel: viewModel)
        case .passions:
            EditorPassionsSectionView(viewModel: viewModel)
        }
    }

    private func title(for section: EditorSection) -> String {
        switch section {
        case .identity:
            return "Identity"
        case .characteristics:
            return "Characteristics"
        case .combatAndDerived:
            return "Combat & Derived"
        case .social:
            return "Social"
        case .economy:
            return "Economy"
        case .passions:
            return "Passions"
        }
    }

    private var navigationTitle: String {
        let name = viewModel.character.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Character Editor" : name
    }
}
