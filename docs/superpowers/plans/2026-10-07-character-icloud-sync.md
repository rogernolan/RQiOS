# Character iCloud Sync Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development to implement the tasks sequentially and review their results.

**Goal:** Sync complete character records through private iCloud while preserving existing device data.

**Architecture:** Adapt the existing SwiftData graph for CloudKit, migrate the existing store with recovery, then configure the private container and account feedback. SwiftData owns cloud mirroring.

**Tech Stack:** Swift, SwiftData, Core Data model inspection, CloudKit, SwiftUI, Swift Testing, Xcode.

## Global Constraints

- Approved design: docs/superpowers/specs/2026-10-07-character-icloud-sync-design.md.
- Bundle identifier com.diffeng.RQSheet; proposed CloudKit container iCloud.com.diffeng.RQSheet.
- Preserve the existing default.store location, full records, relationships, portrait data and experience checks.
- Never reset the store or substitute an empty database on migration failure.
- CloudKit disabled explicitly in unit tests and previews.
- Missing imported relationships must not trigger insertion of replacement children during view reads.
- Independently created same-name characters remain separate.
- Device installation and production schema promotion require a later delivery decision.
- All shell commands use rtk. Work exclusively in /Users/rog/.codex/worktrees/character-icloud-sync/RQiOS.
- Baseline: 150/152 passed; existing More-menu source assertion failures in CharacterWorkspaceChromeTests and NotesViewTests are tracked separately.

### Task 1: CloudKit-compatible graph and legacy migration

**Files:** Character.swift and all nine related model files; SkillSeeder.swift; RunesView.swift and honor-reading views; Persistence/RQSchemaV1.swift, RQSchemaV2.swift, RQMigrationPlan.swift; RQSheetTests/CloudKitSchemaTests.swift, CharacterMigrationTests.swift and Fixtures.

**Produces:** RQSchemaV2.schema (Schema), RQMigrationPlan (SchemaMigrationPlan); optional persisted rune links and safe views.

- [ ] Capture a populated unversioned store through the unchanged model before changing production code. Include every entity, portrait, custom skill, equipment, magic, notes, check flags and distinct elemental rune values. Record that ten tuple-declared paired rune slots are absent from the old persisted schema; migrate those absent slots to the old 50/50 defaults and verify asymmetric pair values survive subsequent saves/reopen. Save original model entity hashes and fixture creation evidence.
- [ ] Write and run failing CloudKit schema tests: for every entity assert no uniqueness constraints; for every attribute assert optional or defaultValue != nil; for every relationship assert optional, inverse present and deleteRule != denyDeleteRule.
- [ ] Freeze the original schema without changing entity hashes. Introduce version 2 and an explicit lightweight/custom migration stage proven against the original fixture.
- [ ] Add scalar defaults, optional persisted links and explicit inverses. Preserve old names through renaming identifiers if backing collections change. Use cascade for character-owned children and nullify for shared definitions and paired rune links.
- [ ] Initialize new characters fully; use optional rune slots in views and compactMap in allRuneAffinities. No child generation during reads. Avoid honor insertion on display.
- [ ] Replace definition uniqueness with per-key seeding. New character seeding picks one definition per key even after duplicate remote definitions arrive; preserve existing references.
- [ ] Test migration graph/value/count preservation across reopen, missing links, duplicate definition seeding and deletion ownership. Existing focused model/import tests must remain passing.
- [ ] Commit only Task 1 files after inspecting the diff and results.

Example schema assertions:
```swift
let model = try #require(NSManagedObjectModel.makeManagedObjectModel(for: RQSchemaV2.schema))
for entity in model.entities {
    #expect(entity.uniquenessConstraints.isEmpty)
    for attribute in entity.attributesByName.values {
        #expect(attribute.isOptional || attribute.defaultValue != nil)
    }
    for relationship in entity.relationshipsByName.values {
        #expect(relationship.isOptional)
        #expect(relationship.inverseRelationship != nil)
    }
}
```

### Task 2: Store recovery and persistence bootstrap

**Files:** Persistence/StoreRecovery.swift, AppPersistence.swift; RQSheetTests/StoreRecoveryTests.swift, AppPersistenceTests.swift; RQSheetApp.swift.

**Consumes:** RQSchemaV2.schema and RQMigrationPlan from Task 1.
**Produces:** AppPersistence.makeContainer(storeURL: URL? = nil, inMemory: Bool = false, cloudKitEnabled: Bool = true) throws -> ModelContainer.

- [ ] Write tests for a consistent pre-migration recovery copy, sidecars/external data, repeated launch, corrupted store and failed opening without destructive reset. Observe expected red failures first.
- [ ] Preserve files before opening the legacy live store. Use a SQLite consistent backup or pre-open copy including WAL/SHM and external data. Persist a successful marker only after migration and full graph verification; do not overwrite the original backup on retries.
- [ ] Use the same default URL as the existing ModelConfiguration. Use the explicit private container for real launches and .none for tests/in-memory containers.
- [ ] Replace fatalError startup with a failure screen and Retry. Retry opens the same store and preserves failure evidence; never creates a fallback empty store.
- [ ] Verify migration and reopen from fixture through AppPersistence. Compare all model values and relationships through a reusable graph snapshot.
- [ ] Commit reviewed Task 2 files and provide completed test results.

### Task 3: iCloud configuration, user feedback and delivery evidence

**Files:** RQSheet.entitlements, project.pbxproj as required, CloudSyncStatus.swift, CloudSyncSettingsView.swift, SettingsView.swift, CharacterListView.swift, previews/test container configuration, docs/icloud-sync.md; CloudSyncStatusTests.swift.

**Consumes:** AppPersistence.makeContainer from Task 2.

- [ ] Test account-status mapping without claiming data-transfer completion. Implement CloudKit account checks with refresh on foreground/account change and show actionable availability messages.
- [ ] Configure iCloud.com.diffeng.RQSheet in entitlements and the explicit persistence configuration. Retain remote notifications.
- [ ] Explain same-account sync, offline editing and separate same-name records in Settings. Update deletion text to say it affects synced devices.
- [ ] Disable CloudKit in all test/preview containers explicitly.
- [ ] Build and run full unit tests on iPhone and relevant integration tests on iPad. Baseline failures must be reported distinctly.
- [ ] Attempt a signed device build without installing, inspect signed entitlements and provisioning. Record any container-registration/account limitations precisely.
- [ ] Document Production schema promotion and a two-device test sequence. Do not claim real-device sync from simulator evidence.
- [ ] Review the full branch, fix material findings, commit the reviewed change and leave the worktree attached.

## Commands

Run each focused test cycle using:
```sh
rtk proxy xcodebuild -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=35D3E526-9398-48CC-AB55-F4927A5E103A' -derivedDataPath /private/tmp/rqsheet-sync-work -only-testing:RQSheetTests/CloudKitSchemaTests CODE_SIGNING_ALLOWED=NO test
```
Use the appropriate named test suite for each cycle. Exit zero and passed-test counts establish success. Keep full logs under /private/tmp; inspect completed xcresult bundles. Before commits run rtk git diff --check and inspect the exact staged files.
