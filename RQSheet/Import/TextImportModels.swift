import Foundation

enum TextImportSection: String, CaseIterable, Equatable {
    case characterInfo = "Character info"
    case attributes = "Attributes"
    case runes = "Runes"
    case skills = "Skills"
    case equipment = "Equipment"
    case magic = "Magic"
    case passions = "Passions"
}

enum TextImportSectionStatus: String, Equatable {
    case green
    case yellow
    case red
}

struct TextImportSectionReview: Equatable {
    let section: TextImportSection
    let status: TextImportSectionStatus
    let detail: String
}

struct ParsedCharacterInfo: Equatable {
    var candidateName: String?
    var family: String?
    var patron: String?
    var originalHouse: String?
    var dateOfBirth: String?
    var occupation: String?
    var reputation: Int?
    var sol: String?
    var income: String?
    var ransom: Int?
    var cult: String?
    var worships: [String] = []
}

struct ParsedPassionEntry: Equatable {
    let name: String
    let percentage: Int
}

struct ParsedSkillEntry: Equatable {
    let name: String
    let groupName: String
    let percentage: Int
    let isCustom: Bool
}

struct ParsedWeaponEntry: Equatable {
    let name: String
    let percentage: Int?
    let damage: String?
    let strikeRank: String?
    let range: String?
}

struct ParsedSpellEntry: Equatable {
    let name: String
    let points: Int
    let source: String
}

struct TextImportCoverage: Equatable {
    var foundIdentityFields: Int = 0
    var expectedIdentityFields: Int = 0
    var foundAttributes: Int = 0
    var expectedAttributes: Int = 0
    var foundRunes: Int = 0
    var expectedRunes: Int = 0
    var foundSkills: Int = 0
    var foundSkillGroups: Int = 0
    var expectedSkillGroups: Int = 0
    var unsupportedSkillGroups: Int = 0
    var foundEquipmentEntries: Int = 0
    var foundMagicEntries: Int = 0
    var foundPassions: Int = 0
}

struct TextImportResult: Equatable {
    var characterInfo = ParsedCharacterInfo()
    var attributes: [RQCharacter.Characteristic: Int] = [:]
    var runePercentages: [RuneName: Int] = [:]
    var passions: [ParsedPassionEntry] = []
    var skills: [ParsedSkillEntry] = []
    var weapons: [ParsedWeaponEntry] = []
    var equipment: [String] = []
    var magic: [ParsedSpellEntry] = []
    var trailingNotes: String?
    var coverage = TextImportCoverage()

    func review() -> [TextImportSectionReview] {
        [
            TextImportSectionReview(
                section: .characterInfo,
                status: characterInfoStatus,
                detail: "\(coverage.foundIdentityFields)/\(coverage.expectedIdentityFields)"
            ),
            TextImportSectionReview(
                section: .attributes,
                status: attributesStatus,
                detail: "\(coverage.foundAttributes)/\(coverage.expectedAttributes)"
            ),
            TextImportSectionReview(
                section: .runes,
                status: runesStatus,
                detail: "\(coverage.foundRunes)/\(coverage.expectedRunes)"
            ),
            TextImportSectionReview(
                section: .skills,
                status: skillsStatus,
                detail: "\(coverage.foundSkills) skills"
            ),
            TextImportSectionReview(
                section: .equipment,
                status: equipmentStatus,
                detail: "\(coverage.foundEquipmentEntries) entries"
            ),
            TextImportSectionReview(
                section: .magic,
                status: magicStatus,
                detail: "\(coverage.foundMagicEntries) entries"
            ),
            TextImportSectionReview(
                section: .passions,
                status: passionsStatus,
                detail: "\(coverage.foundPassions) entries"
            ),
        ]
    }

    private var characterInfoStatus: TextImportSectionStatus {
        guard coverage.expectedIdentityFields > 0 else { return .red }
        if coverage.foundIdentityFields == 0 {
            return .red
        }
        if coverage.foundIdentityFields >= coverage.expectedIdentityFields {
            return .green
        }
        return .yellow
    }

    private var attributesStatus: TextImportSectionStatus {
        guard coverage.expectedAttributes > 0 else { return .red }
        return coverage.foundAttributes >= coverage.expectedAttributes ? .green : .red
    }

    private var runesStatus: TextImportSectionStatus {
        guard coverage.expectedRunes > 0 else { return .red }
        return coverage.foundRunes >= coverage.expectedRunes ? .green : .red
    }

    private var skillsStatus: TextImportSectionStatus {
        if coverage.unsupportedSkillGroups > 0 || coverage.foundSkills == 0 {
            return .red
        }
        if coverage.expectedSkillGroups > 0 && coverage.foundSkillGroups < coverage.expectedSkillGroups {
            return .yellow
        }
        return .green
    }

    private var equipmentStatus: TextImportSectionStatus {
        coverage.foundEquipmentEntries > 0 ? .green : .yellow
    }

    private var magicStatus: TextImportSectionStatus {
        coverage.foundMagicEntries > 0 ? .green : .yellow
    }

    private var passionsStatus: TextImportSectionStatus {
        coverage.foundPassions > 0 ? .green : .yellow
    }
}
