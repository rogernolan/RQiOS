# Character iCloud sync

Status: approved by Rog, 7 October 2026.

RQ Character will sync complete character records between iPhone and iPad signed into the same Apple Account with iCloud available. Edits save locally first; SwiftData sends and receives changes asynchronously. Offline editing remains available. Deleting a character will also delete it on other synced devices.

## Approach

Use SwiftData's managed CloudKit sync with a private database in the proposed container `iCloud.com.diffeng.RQSheet`. Keep the app bundle identifier `com.diffeng.RQSheet` and the existing store location so an update can find current records. Verify that the development team can provision this container before describing signing as complete.

A custom CloudKit sync engine would give more control over conflicts and progress, but would add a separate persistence and reconciliation layer. Manual export/import would transfer records without providing the requested automatic sync. Managed SwiftData sync is the recommended approach.

The inspected project already enables CloudKit and remote notifications, but its container list is empty. Its schema also includes a unique skill-definition key, required rune relationships, and fields without declared defaults. Adding the container alone would not produce a compatible schema.

## Records and relationships

Sync identity, characteristics, notes, portrait data, runes, skills and skill definitions, weapons, hit locations, equipment, spells, honor and passions. Preserve percentages, experience checks, ordering, pair relationships and ownership links during migration.

Give required scalar fields appropriate declared defaults, and make persisted relationships optional with unambiguous inverses. Keep collection access convenient through computed accessors where useful. Update rune consumers to tolerate missing links while records arrive. Reading an incomplete imported character must not insert replacement runes or other child records that could compete with incoming data. Create the full initial graph explicitly when creating a new character.

Remove the unsupported uniqueness constraint on SkillDefinition.key. Seed definitions by missing key and select one definition per key when seeding a new character, including when definitions created independently on two devices later arrive. Preserve existing skill references and user-created definitions. Do not delete duplicate definitions as a side effect of importing cloud data.

Existing character records from both devices enter the private database. Distinct characters stay distinct, including characters with the same name that were independently created or imported. Renaming is an edit, not a change of identity. CloudKit and SwiftData manage concurrent changes; this feature does not add a conflict-history editor or promise deterministic results for simultaneous edits to the same field.

Character deletion removes owned child records while preserving definitions used by other characters. Test the rune-pair graph specifically so deletion does not leave orphaned paired runes.

## Existing data and failure handling

Freeze the current persisted model as the legacy schema and introduce a versioned compatible schema with an explicit migration plan. The legacy definition must match an actual store written by the current unversioned app; a fixture created only through the new migration code is insufficient evidence.

Before the first migration, the persistence bootstrap preserves a consistent recovery copy of the existing database and its required sidecar or external-storage files. It records successful migration only after the migrated store opens and the existing graph passes verification. Recovery copies stay on the device and are never used as another live synced store.

Migration failure leaves the recovery copy intact and presents an error with a retry action. The app must not delete the database, substitute a new empty store, or hide the failure behind a successful fresh launch. On a successful upgrade, existing records remain immediately available and are eligible for upload without manual recreation.

Unit tests and previews explicitly disable CloudKit. An offline or temporarily unavailable iCloud account does not cause a database reset. SwiftData owns account-related mirroring; test sign-out and account changes before shipping, and never implement automatic copying of one account's cached records into another account.

## User feedback

Settings will explain that records sync through iCloud, that both devices need the same Apple Account, and that separately created copies remain separate. Show account availability and actionable account errors without claiming that all records are synced merely because the account is available.

Update the deletion confirmation to explain that deletion applies to synced devices. A complete sync-progress dashboard, sharing with other people and automatic merging of same-name characters are outside this feature.

## Verification and delivery

Before implementation, run the existing unit suite in the worktree. Then add tests for the CloudKit-compatible schema, migration of a populated legacy store, graph preservation across reopen, repeated launch, failed migration recovery, duplicate skill-definition arrivals and deletion ownership. Exercise missing rune and child links without creating new records during reads.

The migration fixture must include every model type, portrait data, notes, custom skills, equipment, magic, experience checks and unequal rune-pair values. Compare values, record counts and relationships before and after migration. Verify that the schema can initialize a CloudKit-backed store; a local in-memory test alone cannot establish compatibility.

Build for iPhone and iPad and inspect signed entitlements and the provisioned container. Check the Development schema and promote it to Production before a Production or TestFlight release. Debug and distribution use different CloudKit environments; test both devices with matching environments.

Actual sync acceptance requires two devices signed into the same Apple Account: create on iPhone, edit on iPad, check notes and portrait transfer, edit offline and reconnect, relaunch, and delete a disposable character. Preserve device stores before installing a migration build. Automated simulator tests establish model and migration behavior; they do not prove real-device iCloud transfer.

No device installation or production schema promotion is included in the design approval. Report implementation, signing, production schema and two-device verification as separate evidence states.

Source: [Apple: Syncing model data across a person's devices](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices).
