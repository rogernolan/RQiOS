# Sync Diagnostics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this task, review it, then perform a whole-change review. Steps use checkbox syntax.

**Goal:** Add useful local, shareable diagnostics before phone/iPad testing.
**Architecture:** A bounded thread-safe recorder writes Apple's unified log and its own local history. A retained CloudKit event monitor and persistence/account call sites feed typed events. Settings exports only this safe history.
**Tech Stack:** Swift, OSLog, CoreData/CloudKit notifications, SwiftUI native sharing, Swift Testing.

## Global Constraints

- Spec: docs/superpowers/specs/2026-10-08-sync-diagnostics-design.md; scope approved by Rog's “add those.”
- Work exclusively in /Users/rog/.codex/worktrees/character-icloud-sync/RQiOS, branch codex/character-icloud-sync. All shell commands use rtk.
- Bundle/log subsystem com.diffeng.RQSheet; private container iCloud.com.diffeng.RQSheet.
- Maximum 200 retained events and 256 KiB persisted diagnostics; trim oldest. Diagnostics failures never block persistence or alter model data.
- No localized error descriptions, arbitrary userInfo, account identifiers, record IDs, paths, character content, credentials or tokens in recorded/exported data. Partial errors retain codes, never keys.
- Record account availability separately from data transfer; never claim all records synced.
- Tests/previews remain local with CloudKit disabled except deliberate opt-in probe. No schema/migration semantics, device installation, Production promotion, push or merge changes.
- Rog explicitly requests fixing all three prior failures: the two More-menu source assertion tests and random-POW magic test. Task 2 owns those fixes. Do not skip them to achieve a green count.

### Task 1: Bounded diagnostics, event monitoring and app integration

**Files:** Create RQSheet/Diagnostics/SyncDiagnostics.swift, SyncErrorSummary.swift, CloudSyncEventMonitor.swift, SyncDiagnosticsSharingView.swift as focused responsibilities require; create RQSheetTests/SyncDiagnosticsTests.swift and CloudSyncEventMonitorTests.swift. Modify RQSheet/AppPersistence.swift, Persistence/StoreRecovery.swift, RQSheetApp.swift, CloudSyncStatus.swift, CloudSyncSettingsView.swift and corresponding existing tests; document in docs/icloud-sync.md.

**Interfaces:** Recorder provides a production shared instance and an injectable initializer accepting a temporary directory, bounded limits and clock/session metadata for deterministic tests. Use typed enums/fields rather than generic free-form messages. Error summaries consume Error and retain only allowlisted domain/category + code, retry-after and bounded underlying/partial codes. Monitor consumes NotificationCenter/recorder, observes NSPersistentCloudKitContainer.eventChangedNotification, is idempotent and can stop for teardown. Production starts monitor before makeContainer. makeContainer accepts a defaulted diagnostic dependency so tests can capture exact events without changing existing calls. CloudSyncStatus also accepts a defaulted recorder; preserve trailing-closure account-provider tests. Sharing produces a fresh plain-text snapshot only on explicit user action.

- [ ] Write meaningful tests before implementation: event limit eviction/reopen and byte bound; corrupt/unwritable history does not throw through logging; concurrent writes leave readable bounded history; marker strings placed in NSError descriptions/userInfo/partial keys do not appear; underlying/partial numeric codes and finite retry-after survive. Verify expected missing APIs/behavior failures, not unrelated build errors.
- [ ] Implement the smallest recorder/error summary and tests. Use atomic local writes and serialized access. OSLog errors must not recursively log into failing file persistence. Imported/corrupt history must be validated against the same allowed schema before export.
- [ ] Test and implement monitor ownership/start-stop idempotence and safe event mapping. Notification callbacks must be safe for their delivery queue; do not reach private SwiftData internals. Fixed setup/import/export states identify start/completion using event dates and succeeded/error. Ignore unrelated malformed notifications safely.
- [ ] Test bootstrap events with a real copied legacy fixture, corrupt store, verified repeat launch and diagnostic file failure. Instrument existing stages without changing backup/verification/marker ordering. Never log live file paths or graph values. Keep observers installed through startup error/retry.
- [ ] Add account check/error/change events with reason enums for appearance/manual/foreground/account-change where useful. Extend existing status tests to assert safe diagnostic values and retained coalesced refresh behavior. Keep Settings account wording intact.
- [ ] Add Share Sync Diagnostics to iCloud Settings using native sharing on iPhone/iPad, fresh snapshot on request, export failure UI and scoped metadata. No external upload occurs until user chooses a share destination. Verify report tests exclude all marker data and contain version/build/container/session/event timestamps.
- [ ] Document local retention/location, collection using Settings and Console subsystem filters, correlation between phone/iPad reports and Apple background logs, limits and test acceptance. Do not claim runtime environment or completed transfer from signing/event availability.
- [ ] Run focused diagnostics/account/persistence tests on iPhone simulator35D3E526-9398-48CC-AB55-F4927A5E103A and iPad relevant tests. Recheck available runtime; boot Shutdown simulator without shutting down shared ones. Use isolated /private/tmp derived data, -parallel-testing-enabled NO -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO. Task 2 runs the full unit regression after all final changes. Keep full output in /private/tmp.
- [ ] Run signed generic device build with -allowProvisioningUpdates, verify actual codesign/profile expected team975JU2ENN7/bundle/container. Do not install. diff --check, inspect exact owned staged files, commit and report commands/results/limits in .superpowers/sdd/diagnostics-report.md.

### Task 2: Fix every previously failing test and verify the combined change

**Files:** RQSheetTests/CharacterWorkspaceChromeTests.swift, NotesViewTests.swift, CharacterMagicTests.swift; narrowly scoped workspace/model changes only if investigation proves a real defect; docs/icloud-sync.md final evidence.

**Requirements:** User says “fix them even if you don't think they're your fault.” Preserve intended UI and model behavior while correcting the test defects. Two source-text tests fail four assertions: chrome expects exact MorePopupBubbleShape() despite required notch argument, both tests blanket-ban NavigationLink despite the character edit toolbar using it, and Notes' substring Menu { also matches isShowingExtrasMenu {. POW test rolls3...18 then assumes reducing to6; make both clamp-down and increase-without-refill cases deterministic. Do not weaken assertions or remove meaningful navigation/ownership checks; replace global substring bans with focused checks of the More destination/menu, preserving editor navigation.

- [ ] Reproduce three suites before edits. For random test, demonstrate its incorrect setup with fixed starting POW4/current4 and expected unchanged current after setting6, and specify a deterministic high initial POW/current for actual reduction. Do not run high-count loops hoping for random failure.
- [ ] Inspect CharacterWorkspaceView actual editor/More route and existing UI tests. Correct scoped assertions for the parameterized notch shape and actual route semantics. If source assertions must remain, delimit named More sections or use exact regex tokens so suffixes of identifiers do not match a Menu declaration. Keep substantive routing/content/notch assertions.
- [ ] Make the reducing test explicitly start at POW12/current12 then reduce to6; make increasing test explicitly start POW4/current2 then increase10. Include a boundary assertion for initially-low current if needed to exercise the observed case. No production model change unless a behavior defect is demonstrated.
- [ ] Run focused three suites plus diagnostics/status/persistence from Task1, then full RQSheetTests once. Use -parallel-testing-enabled NO -collect-test-diagnostics never and completed xcresult summary to establish passed/failed/skipped counts. The only intended skip is opt-in CloudKit probe; run that separately if diagnostics monitor evidence needs it. If further failures appear, investigate and fix them within user's request for a clean suite.
- [ ] Run appropriate iPad tests after UI source assertion fixes; update durable automated evidence to supersede prior167/171 state with exact fresh counts/log paths. Stage reviewed files, diff --check, commit, write .superpowers/sdd/test-fixes-report.md. No physical install, schema promotion, push or merge.
