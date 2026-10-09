# Unversioned legacy store fixture

`legacy.store` was generated on 7 October 2026 with the unchanged application model at baseline commit `4d96bf1`, before production model changes. The generator is preserved with its corrected six-rune count assertion in `LegacyStoreCaptureTests.swift.txt`; it is evidence, not an executable test using today's models.

Generation ran on the iPhone 17 Pro iOS 26.2 simulator. The original store was written to host `/private/tmp/rq-legacy-fixture`, checkpointed, and copied here. SHA-256: `8254b56d83c49c7ccc1b44a93a54eb32c18de52b1c5e0d96dfc43e1b1ea21452`.

`entity-hashes.json` and `model-inspection.txt` were emitted by `NSManagedObjectModel.makeManagedObjectModel(for:)` against the original application types. The frozen V1 hash test proves equality for all ten original entities. `counts.json` and `original-graph.json` record every stored row, scalar value, blob and relationship ID from the checkpointed database.

The original SwiftData model persisted only the six elemental rune slots. Its ten tuple-declared paired rune slots were absent from the actual model; their edited values and ownership links were never saved. The generator intentionally exercises unequal pairs but does not manufacture orphan rows. Migration preserves the six stored runes and initializes the ten new persisted slots at the old 50/50 defaults. Tests change those new pairs to unequal values and prove they survive reopen.

Tests copy this fixture before opening it. Do not regenerate it through V1 or V2, migrate it in place, or commit generated WAL/SHM sidecars. The fixture has 22 records across all ten entity types, including portrait bytes, a custom skill/definition, experience checks, weapon damage/equipment, hit locations, honor, passion, equipment, two magic kinds and notes.

Capture test result: `/private/tmp/rq-sync-task1-derived/Logs/Test/Test-RQSheet-2026.10.07_15-46-00-+0100.xcresult`. Its initial expected 16-rune assertion failed because actual persisted count was six; the store and model inspection had already been saved. The expectation was corrected after inspection. Original CloudKit compatibility RED produced 80 schema failures. Subsequent exact V1 hash equality and legacy-to-V2 migration/reopen passed before the full-graph snapshot test was added.
