# Character sync through iCloud

RQSheet uses SwiftData with the private CloudKit container `iCloud.com.diffeng.RQSheet`. The app identifier is `com.diffeng.RQSheet`, under team `975JU2ENN7`. Sync is for one person's iPhone and iPad signed in to the same Apple Account and using the same CloudKit environment. There is no sharing workflow.

SwiftData owns background transfer and conflict handling. Offline edits stay in the local store and transfer when iCloud becomes available. Settings checks account availability on appearance, foreground entry, account changes and manual refresh. An available account does not establish that every edit has uploaded or downloaded. Characters with the same name remain separate records. Deleting a character also deletes it from synced devices.

## Existing stores and recovery

The app keeps the existing default store location. Before migrating an existing store, it preserves raw database/WAL/SHM bytes and external data in `<store>.recovery/raw/`, then creates a consistent committed snapshot in `<store>.recovery/original/`. These original copies are never overwritten. Migration runs locally before the CloudKit container opens and verifies original records, values and ownership links. `verified-v2` records successful verification and final container initialization, not upload completion.

Legacy paired-rune slots were never saved; migration supplies the old 50/50 defaults and later edits persist. If migration, verification or store opening fails, startup offers Retry and preserves evidence. There is no empty-store fallback. A missing live store with recovery evidence is rejected rather than recreated. Preserve the complete live store and recovery directory before investigating; do not reinstall or manually replace files while the app is running. Recovery copies are local evidence, not alternate synced stores.

## Signing and provisioning evidence

On 8 October 2026, the first generic device build failed because Xcode reported no developer account and the cached profile did not authorize the new container. After Rog confirmed Jane Nolan's signing team in Xcode, a fresh build with `-allowProvisioningUpdates` succeeded. The earlier signing blocker is cleared. Direct inspection of CloudKit Console also confirmed `iCloud.com.diffeng.RQSheet` in both the container selector and the selected Development page URL, matching Xcode and the signed profile.

The signed app passed `codesign --verify --deep --strict`. Its actual entitlements and embedded provisioning profile agree on application identifier `975JU2ENN7.com.diffeng.RQSheet`, team `975JU2ENN7`, and container `iCloud.com.diffeng.RQSheet`. The app authorizes the CloudKit service and development push notifications; the profile permits CloudKit services. The profile permits both Development and Production CloudKit environments; the signed app has no explicit `com.apple.developer.icloud-container-environment` entitlement, so the profile's permitted values alone do not prove the database environment used at runtime. Verify the runtime environment during device acceptance.

Xcode shows Jane Nolan's development certificate and signing team. That developer identity authorizes the app; private character data belongs to the Apple Account signed in on each device. Both devices must use the same Apple Account to sync their private records.

Build command: `rtk proxy xcodebuild -project RQSheet.xcodeproj -scheme RQSheet -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/rq-sync-signing-recheck -allowProvisioningUpdates build`. Completed log: `/private/tmp/rq-sync-signing-recheck.log`. Signed product: `/private/tmp/rq-sync-signing-recheck/Build/Products/Debug-iphoneos/RQSheet.app`, version 1.0, build 1. Provisioning now authorizes the container; actual CloudKit database access, asynchronous mirroring, physical installation and real-device transfer remain unverified. No device was installed or Production schema promoted.

## Development and Production

Development and Production use separate databases. Verify the signed build's environment on both devices; a same-account pair with different environments does not share records. Before a Production release, initialize and exercise every model and relationship with disposable Development data, verify the generated schema and indexes in CloudKit Console, and complete the two-device sequence below.

Rog then reviews the Development-to-Production schema changes in the CloudKit Database app and deploys the schema to Production. This is a manual release gate; it has not been performed. Schema deployment does not copy Development records. Repeat acceptance with builds signed for Production before relying on Production sync. Apple documents [SwiftData device sync](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices) and [schema deployment](https://developer.apple.com/documentation/cloudkit/deploying-an-icloud-container-s-schema).

## Two-device acceptance

Use a disposable character and preserve real character data before any testing.

1. Verify matching app version, Apple Account, container and signed CloudKit environment on iPhone and iPad. Confirm account availability in Settings.
2. On iPhone, create the disposable character with a unique test name. Fill notes, portrait, characteristics, paired runes, skills and weapon links, equipment, spells, hit locations, honor and passions. Wait for it to appear on iPad and compare all values and ownership links.
3. Edit different fields on each device, reconnect and verify both devices converge. Then edit the same field on both devices and verify SwiftData resolves to the same eventual value; no custom conflict UI is provided.
4. Put one device offline, edit and relaunch it, and confirm local persistence. Reconnect, foreground both apps and verify convergence without duplicate children or lost links.
5. Create a separate character with the same name and verify both records survive. Edit built-in skill data and verify it is not overwritten by seeding on relaunch.
6. Delete a disposable child and verify it disappears on the other device. Delete the disposable character, confirm the synced-device warning, and verify its children disappear without affecting the same-name character. Relaunch both devices and verify the deletion stays applied.
7. With preserved real data and disposable Development records, sign out of iCloud on one device while leaving the other signed in to account A. Foreground the app and manually refresh Settings; record the unavailable status, which local records remain visible, and whether a local edit survives relaunch. Sign back into A, refresh and verify availability and eventual convergence with the other device.
8. On that test device, switch from account A to a disposable account B in the same signed environment. Refresh Settings and record account availability and local-record behavior. Verify account A's cached records are not copied into B's private database: inspect B's records in CloudKit Console and use a clean local app store signed into B to confirm A's unique disposable records do not arrive. Create a unique B record and verify it does not arrive on the device still signed into A. Switch back to A and verify A's preserved records and edits converge without B's record. Stop and preserve live/recovery evidence if isolation or preservation fails. This checks account transitions for one user's phone/iPad; it does not introduce a multiuser app workflow.
9. Review migrated existing characters on the originating device and their arrival on the second device. If a startup error appears, stop and preserve the live store plus recovery directory.

Record device/build/environment, observations and completion time. An availability message or simulator test alone does not satisfy these checks.

## Automated evidence

The iPhone 26.2 unit run executed 171 tests: 167 passed, three failed and one opt-in CloudKit probe was skipped. Two failures are existing More-menu source assertions. The third is an unrelated random-POW test: it starts with a random POW of 3–18, sets POW to six, and assumes the previous current magic points were at least six (observed four). The focused iPad 26.2 integration run passed all 26 tests, including that test. Existing view-test State warnings remain in the full run.

The final focused account-status run passed all three mapping, error-recovery and overlapping-refresh tests. Ordinary test and preview containers explicitly disable CloudKit. A separate opt-in probe initialized a fresh temporary on-disk CloudKit-configured container, checked its explicit container identifier and empty character store, and passed. The actual simulator executable's `__entitlements` section contains the expected team/application identifier, CloudKit container/service and development push entitlement. Simulator ad-hoc code signing uses injected Mach-O entitlements; the separate signed-device build above establishes device provisioning.

The probe establishes synchronous ModelContainer acceptance, not successful asynchronous mirror setup or transfer: disposal of its temporary container logged mirroring teardown/store-removed messages with Core Data error code `134060` on scope exit. This teardown observation does not prove asynchronous mirroring initialization completed. No signed-in simulator account, registered container access or live iCloud transfer was established. Full commands, logs and result-bundle evidence are in the local Task 3 report.
