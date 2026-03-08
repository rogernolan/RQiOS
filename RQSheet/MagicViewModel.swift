import Foundation
import Observation

struct CommonRuneSpellReference: Identifiable, Equatable {
    let name: String
    let pointsText: String
    let page: String

    var id: String { name }
}

@MainActor
@Observable
final class MagicViewModel {
    let character: RQCharacter
    var searchText = ""
    var pendingDeleteSpell: CharacterSpell?

    static let commonRuneSpellCatalog: [CommonRuneSpellReference] = [
        CommonRuneSpellReference(name: "Command Cult Spirit", pointsText: "2", page: "323"),
        CommonRuneSpellReference(name: "Dismiss Magic", pointsText: "1+", page: "326"),
        CommonRuneSpellReference(name: "Divination", pointsText: "1+", page: "327"),
        CommonRuneSpellReference(name: "Extension", pointsText: "1+", page: "328"),
        CommonRuneSpellReference(name: "Find Enemy", pointsText: "1", page: "328"),
        CommonRuneSpellReference(name: "Heal Wound", pointsText: "1", page: "330"),
        CommonRuneSpellReference(name: "Multispell", pointsText: "1+", page: "335"),
        CommonRuneSpellReference(name: "Sanctify", pointsText: "1+", page: "338"),
        CommonRuneSpellReference(name: "Soul Sight", pointsText: "1", page: "340"),
        CommonRuneSpellReference(name: "Spirit Block", pointsText: "1+", page: "341"),
        CommonRuneSpellReference(name: "Summon Cult Spirit", pointsText: "1–3", page: "342"),
        CommonRuneSpellReference(name: "Warding", pointsText: "1+", page: "347"),
    ]

    init(character: RQCharacter) {
        self.character = character
    }

    var visibleSpiritSpells: [CharacterSpell] {
        visibleSpells(for: .spiritMagic)
    }

    var visibleRuneSpells: [CharacterSpell] {
        visibleSpells(for: .runeSpell)
    }

    var visibleCommonRuneSpells: [CommonRuneSpellReference] {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.isEmpty == false else {
            return Self.commonRuneSpellCatalog
        }

        let nameMatches = Self.commonRuneSpellCatalog.filter { spell in
            spell.name.localizedStandardContains(trimmedQuery)
        }
        let pageMatches = Self.commonRuneSpellCatalog.filter { spell in
            spell.name.localizedStandardContains(trimmedQuery) == false &&
            spell.page.localizedStandardContains(trimmedQuery)
        }

        return nameMatches + pageMatches
    }

    var spiritCastingPercentageText: String {
        "\(character.pow * 5)%"
    }

    var magicPointsText: String {
        "\(character.currentMagicPoints) / \(character.maxMagicPoints)"
    }

    var runePointsText: String {
        "\(character.runePoints)"
    }

    @discardableResult
    func addNewSpell(name: String, points: Int, page: String, kind: SpellKind) -> CharacterSpell {
        character.addSpell(name: name, points: points, page: page, kind: kind)
    }

    func updateSpell(_ spell: CharacterSpell, name: String, points: Int, page: String) {
        spell.name = name
        spell.points = max(0, points)
        spell.page = page
    }

    func updateCurrentMagicPoints(_ value: Int) {
        character.currentMagicPoints = value
    }

    func updateRunePoints(_ value: Int) {
        character.runePoints = value
    }

    func requestDelete(_ spell: CharacterSpell) {
        pendingDeleteSpell = spell
    }

    func cancelDelete() {
        pendingDeleteSpell = nil
    }

    func confirmDelete() {
        guard let pendingDeleteSpell else { return }
        character.spells.removeAll { $0 == pendingDeleteSpell }
        self.pendingDeleteSpell = nil
    }

    private func visibleSpells(for kind: SpellKind) -> [CharacterSpell] {
        let orderedSpells = character.spells
            .filter { $0.kind == kind }
            .sorted { lhs, rhs in
                lhs.sortOrder < rhs.sortOrder
            }

        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.isEmpty == false else {
            return orderedSpells
        }

        let nameMatches = orderedSpells.filter { spell in
            spell.name.localizedStandardContains(trimmedQuery)
        }
        let pageMatches = orderedSpells.filter { spell in
            spell.name.localizedStandardContains(trimmedQuery) == false &&
            spell.page.localizedStandardContains(trimmedQuery)
        }

        return nameMatches + pageMatches
    }
}
