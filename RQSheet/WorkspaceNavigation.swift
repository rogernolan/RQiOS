import Foundation

nonisolated enum WorkspaceTab: String, Hashable {
    case summary, combat, skills, runes, extras
}

nonisolated enum WorkspaceSection: String, CaseIterable, Hashable {
    case summary, combat, skills, runes, magic, equipment, notes, settings

    static let extras: [Self] = [.magic, .equipment, .notes, .settings]

    var title: String {
        switch self {
        case .summary: "Summary"
        case .combat: "Combat"
        case .skills: "Skills"
        case .runes: "Runes"
        case .magic: "Magic"
        case .equipment: "Equipment"
        case .notes: "Notes"
        case .settings: "Settings"
        }
    }

    var runeName: String {
        switch self {
        case .summary: "RuneMan"
        case .combat: "RuneDeath"
        case .skills: "RuneMastery"
        case .runes: "RuneInfinity"
        case .magic: "RuneMagic"
        case .equipment: "RuneTrade"
        case .notes: "RuneTruth"
        case .settings: "RuneDisorder"
        }
    }

    var phoneTab: WorkspaceTab {
        WorkspaceTab(rawValue: rawValue) ?? .extras
    }
}

nonisolated struct WorkspaceNavigation {
    private(set) var section: WorkspaceSection = .summary
    private(set) var extrasSection: WorkspaceSection?

    var phoneTab: WorkspaceTab { section.phoneTab }

    mutating func select(_ section: WorkspaceSection) {
        self.section = section
        if section.phoneTab == .extras {
            extrasSection = section
        }
    }

    /// Returns true when More needs a destination choice before changing sections.
    mutating func selectPhoneTab(_ tab: WorkspaceTab) -> Bool {
        if tab == .extras {
            guard let extrasSection else { return true }
            select(extrasSection)
        } else if let section = WorkspaceSection(rawValue: tab.rawValue) {
            select(section)
        }
        return false
    }
}
