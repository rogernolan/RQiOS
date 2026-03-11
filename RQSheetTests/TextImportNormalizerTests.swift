import Testing
@testable import RQSheet

struct TextImportNormalizerTests {
    @Test
    func normalizeUnifiesLineEndingsAndRemovesBadgeNoise() {
        let raw = "Name: Ornstal\r\nBorn: Microbadge: Glorantha fan: Motion rune 1604\rCult: Initiate of LHANKOR MHY Microbadge: Glorantha fan: Truth rune"

        let normalized = TextImportNormalizer.normalize(raw)

        #expect(normalized.contains("\r") == false)
        #expect(normalized.contains("Microbadge: Glorantha fan:") == false)
        #expect(normalized.contains("Name: Ornstal\nBorn: 1604\nCult: Initiate of LHANKOR MHY"))
    }

    @Test
    func canonicalFieldTextCollapsesUnsafeSpacingOnlyForMatching() {
        let text = "  POWER   RUNE      \n   AFFINITIES  "

        let canonical = TextImportNormalizer.canonicalFieldText(text)

        #expect(canonical == "POWER RUNE AFFINITIES")
    }

    @Test
    func placeholderDetectionCatchesCommonSheetMarkers() {
        #expect(TextImportNormalizer.isPlaceholder("___"))
        #expect(TextImportNormalizer.isPlaceholder("--%"))
        #expect(TextImportNormalizer.isPlaceholder("##"))
        #expect(TextImportNormalizer.isPlaceholder("?"))
        #expect(TextImportNormalizer.isPlaceholder("__/__"))
        #expect(TextImportNormalizer.isPlaceholder("35%") == false)
        #expect(TextImportNormalizer.isPlaceholder("Lanbril") == false)
    }
}
