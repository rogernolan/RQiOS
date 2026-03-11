import Foundation

enum TextImportPipeline {
    static func parse(_ rawText: String) throws -> TextImportResult {
        let sections = try TextImportSectionDetector.detect(in: rawText)

        var combined = TextImportResult()
        merge(TextImportCoreSectionParser.parse(sections), into: &combined)
        merge(TextImportSkillsParser.parse(sections), into: &combined)
        merge(TextImportEquipmentAndMagicParser.parse(sections), into: &combined)
        return combined
    }

    private static func merge(_ other: TextImportResult, into combined: inout TextImportResult) {
        if other.characterInfo != ParsedCharacterInfo() {
            combined.characterInfo = other.characterInfo
        }
        combined.attributes.merge(other.attributes) { _, new in new }
        combined.runePercentages.merge(other.runePercentages) { _, new in new }
        combined.passions.append(contentsOf: other.passions)
        combined.skills.append(contentsOf: other.skills)
        combined.weapons.append(contentsOf: other.weapons)
        combined.equipment.append(contentsOf: other.equipment)
        combined.magic.append(contentsOf: other.magic)
        combined.trailingNotes = other.trailingNotes ?? combined.trailingNotes

        if other.coverage.foundIdentityFields > 0 || other.coverage.expectedIdentityFields > 0 {
            combined.coverage.foundIdentityFields = other.coverage.foundIdentityFields
            combined.coverage.expectedIdentityFields = other.coverage.expectedIdentityFields
        }
        if other.coverage.foundAttributes > 0 || other.coverage.expectedAttributes > 0 {
            combined.coverage.foundAttributes = other.coverage.foundAttributes
            combined.coverage.expectedAttributes = other.coverage.expectedAttributes
        }
        if other.coverage.foundRunes > 0 || other.coverage.expectedRunes > 0 {
            combined.coverage.foundRunes = other.coverage.foundRunes
            combined.coverage.expectedRunes = other.coverage.expectedRunes
        }
        if other.coverage.foundSkills > 0 || other.coverage.expectedSkillGroups > 0 || other.coverage.unsupportedSkillGroups > 0 {
            combined.coverage.foundSkills = other.coverage.foundSkills
            combined.coverage.foundSkillGroups = other.coverage.foundSkillGroups
            combined.coverage.expectedSkillGroups = other.coverage.expectedSkillGroups
            combined.coverage.unsupportedSkillGroups = other.coverage.unsupportedSkillGroups
        }
        if other.coverage.foundEquipmentEntries > 0 {
            combined.coverage.foundEquipmentEntries = other.coverage.foundEquipmentEntries
        }
        if other.coverage.foundMagicEntries > 0 {
            combined.coverage.foundMagicEntries = other.coverage.foundMagicEntries
        }
        if other.coverage.foundPassions > 0 {
            combined.coverage.foundPassions = other.coverage.foundPassions
        }
    }
}
