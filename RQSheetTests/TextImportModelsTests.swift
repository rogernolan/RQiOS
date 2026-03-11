import Testing
@testable import RQSheet

struct TextImportModelsTests {
    @Test
    func reviewUsesExpectedPerSectionStatusRules() {
        var result = TextImportResult()
        result.coverage = TextImportCoverage(
            foundIdentityFields: 7,
            expectedIdentityFields: 10,
            foundAttributes: 7,
            expectedAttributes: 7,
            foundRunes: 16,
            expectedRunes: 16,
            foundSkills: 42,
            foundSkillGroups: 6,
            expectedSkillGroups: 6,
            unsupportedSkillGroups: 0,
            foundEquipmentEntries: 3,
            foundMagicEntries: 0,
            foundPassions: 0
        )

        let review = result.review()

        #expect(review.first(where: { $0.section == .characterInfo })?.status == .yellow)
        #expect(review.first(where: { $0.section == .attributes })?.status == .green)
        #expect(review.first(where: { $0.section == .runes })?.status == .green)
        #expect(review.first(where: { $0.section == .skills })?.status == .green)
        #expect(review.first(where: { $0.section == .equipment })?.status == .green)
        #expect(review.first(where: { $0.section == .magic })?.status == .yellow)
        #expect(review.first(where: { $0.section == .passions })?.status == .yellow)
    }

    @Test
    func reviewMarksAttributesAndRunesRedWhenIncomplete() {
        var result = TextImportResult()
        result.coverage = TextImportCoverage(
            foundIdentityFields: 0,
            expectedIdentityFields: 10,
            foundAttributes: 5,
            expectedAttributes: 7,
            foundRunes: 7,
            expectedRunes: 16,
            foundSkills: 2,
            foundSkillGroups: 1,
            expectedSkillGroups: 6,
            unsupportedSkillGroups: 0,
            foundEquipmentEntries: 0,
            foundMagicEntries: 1,
            foundPassions: 1
        )

        let review = result.review()

        #expect(review.first(where: { $0.section == .characterInfo })?.status == .red)
        #expect(review.first(where: { $0.section == .attributes })?.status == .red)
        #expect(review.first(where: { $0.section == .runes })?.status == .red)
        #expect(review.first(where: { $0.section == .skills })?.status == .yellow)
    }

    @Test
    func reviewMarksSkillsRedWhenUnsupportedGroupExists() {
        var result = TextImportResult()
        result.coverage = TextImportCoverage(
            foundIdentityFields: 10,
            expectedIdentityFields: 10,
            foundAttributes: 7,
            expectedAttributes: 7,
            foundRunes: 16,
            expectedRunes: 16,
            foundSkills: 12,
            foundSkillGroups: 5,
            expectedSkillGroups: 6,
            unsupportedSkillGroups: 1,
            foundEquipmentEntries: 1,
            foundMagicEntries: 2,
            foundPassions: 3
        )

        let review = result.review()

        #expect(review.first(where: { $0.section == .skills })?.status == .red)
    }

    @Test
    func parsedCharacterInfoPreservesCultAndWorshipsSeparately() {
        let info = ParsedCharacterInfo(
            candidateName: "Selina",
            family: "Lorionaeo",
            patron: "Marele",
            originalHouse: "Irnilha",
            dateOfBirth: "1604",
            occupation: "Overseer",
            reputation: 12,
            sol: "Free",
            income: "80 L",
            ransom: 500,
            cult: "Issaries",
            worships: ["Lanbril"]
        )

        #expect(info.cult == "Issaries")
        #expect(info.worships == ["Lanbril"])
        #expect(info.candidateName == "Selina")
    }
}
