# iPad Column and Character Card Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pack the iPad worksheet into balanced ordered columns, divide skill areas dynamically between two tiles, and replace the character list with adaptive summary cards.

**Architecture:** Keep the existing iPhone tabs and shared section views. Give the iPad tile page an ordered custom layout that measures each tile and partitions contiguous sections into columns; compute a contiguous skill-area split from the selected character’s saved skills. Render the character picker in a width-aware `LazyVGrid` using the current navigation destination and SwiftData model.

**Tech Stack:** SwiftUI, SwiftData, Swift Testing, XCTest, iOS 26.2 minimum.

## Global Constraints

- Windows narrower than 680 points use the existing iPhone tabbed workspace.
- iPad portrait uses two columns and landscape uses three columns.
- Worksheet reading order remains Summary, Runes, Combat, Magic, Skills 1, Skills 2, Equipment, Notes in portrait and Summary, Runes, Magic, Combat, Skills 1, Skills 2, Equipment, Notes in landscape.
- Tile columns preserve that order, contain contiguous ranges, and use one outer vertical scroll view.
- iPad Summary omits top rune affinities and skill bonuses; iPhone Summary retains them.
- Character cards show portrait, name, family, primary god, and four top runes; no rune percentages.
- Existing persistence, navigation destinations, and destructive delete confirmation remain intact.

---

### Task 1: Pure ordered column and skill partitioning

**Files:**
- Modify: `RQSheet/IPadTileLayout.swift`
- Modify: `RQSheetTests/IPadTileLayoutTests.swift`

**Interfaces:**
- Produce `IPadTileArrangement.order` as the orientation-specific flattened `[IPadCharacterTile]` and `columnCount` for the available size.
- Produce a pure contiguous partition helper that accepts ordered item heights and a column count and returns contiguous ranges minimizing `max(columnHeight) - min(columnHeight)`; ties choose the earliest boundaries.
- Produce a pure skill split helper accepting counts keyed by `SkillGroup`, returning two non-empty contiguous groups in `SkillGroup.allCases` order. Estimate height as `skillCount * rowHeight + areaCount * (headingHeight + addControlHeight)` and choose the split minimizing height difference, with earliest-boundary tie break.

- [x] **Step 1: Write tests for ordered orientation sequences, compact threshold, contiguous column partitioning, optimal boundaries, dynamic skill groups, and ties.** Include empty skills, equal counts, and uneven counts. Update old fixed `.skills`/`.knowledge` assertions to the two dynamic tile identities.
- [x] **Step 2: Run the focused Swift Testing target and confirm failures are from the missing interfaces or changed expected behavior.**
- [x] **Step 3: Implement the pure order and partition helpers with deterministic tie handling.**
- [x] **Step 4: Run `rtk proxy xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' -derivedDataPath /private/tmp/rq-ipad-columns -parallel-testing-enabled NO -only-testing:RQSheetTests/IPadTileLayoutTests CODE_SIGNING_ALLOWED=NO` and confirm the focused tests pass.**

### Task 2: Measured vertical tile columns and dynamic skill sections

**Files:**
- Modify: `RQSheet/IPadTileLayout.swift`
- Modify: `RQSheet/IPadCharacterTilesView.swift`
- Modify: `RQSheet/SkillsView.swift`
- Modify: `RQSheet/StatsOverviewView.swift`
- Modify: `RQSheetTests/IPadTileLayoutTests.swift`
- Modify: `RQSheetUITests/WorkspaceNavigationUITests.swift`

**Interfaces:**
- `IPadTileLayout` consumes the orientation order and measured intrinsic tile heights, then places each tile top-to-bottom in its assigned column.
- `SkillsView(character:groups:)` continues to render only supplied skill areas in tile mode and all areas in phone mode.
- `IPadCharacterTilesView` computes each skill area’s count from the selected character’s live skills and supplies the helper’s two groups to “Skills 1” and “Skills 2”.

- [x] **Step 1: Add layout/UI assertions for order-preserving columns, the two skill tile titles, area coverage without duplication, and absence of top rune affinities/skill bonuses from iPad Summary.**
- [x] **Step 2: Run the focused unit test and iPad UI test to observe failures before production changes.**
- [x] **Step 3: Replace row placement with measured column placement while preserving one canonical tile identity per section. Keep `ScrollViewReader` as the only worksheet scroll container and retain editor scroll anchors.**
- [x] **Step 4: Compute skill counts from the selected character’s current SwiftData skills, partition the seven areas dynamically, and label both tiles “Skills 1” and “Skills 2”.**
- [x] **Step 5: Verify the existing iPad Summary tile presentation excludes top rune affinities and skill bonuses and does not use the portrait scroll-driven photo animation; keep the existing iPhone Summary branch.** This tile-specific presentation already existed, so no `StatsOverviewView.swift` production change was needed.
- [x] **Step 6: Run the layout and iPad orientation UI tests.**

### Task 3: Adaptive character cards

**Files:**
- Modify: `RQSheet/CharacterListView.swift`
- Modify: `RQSheetTests/CharacterListViewTests.swift`
- Modify: `RQSheetUITests/WorkspaceNavigationUITests.swift`

**Interfaces:**
- `CharacterListView` uses one flexible column below 680 points and two at or above 680 points.
- Each `CharacterPickerCard` displays portrait, name, optional family, optional first worship/cult as primary god, and the first four values from `topSummaryRunes()`.
- The card’s `NavigationLink(value: character.persistentModelID)` uses the existing destination; a card action menu opens the existing delete confirmation.

- [x] **Step 1: Add UI coverage for metadata/rune count, single-column compact layout, two-column regular-width layout, detail navigation, and delete confirmation.**
- [x] **Step 2: Run the focused picker tests and confirm the card assertions fail against the current list.**
- [x] **Step 3: Replace `List` with a width-aware `ScrollView`/`LazyVGrid`; keep create-character behavior, route card taps through the existing persistent identifier, and preserve the confirmation dialog for deletion.**
- [x] **Step 4: Run the focused picker tests and iPad/iPhone picker UI checks.**

### Task 4: Regression verification and delivery

**Files:**
- Review changes in: `RQSheet/IPadTileLayout.swift`, `RQSheet/IPadCharacterTilesView.swift`, `RQSheet/SkillsView.swift`, `RQSheet/StatsOverviewView.swift`, `RQSheet/CharacterListView.swift`, relevant unit/UI tests, and this plan.

- [x] **Step 1: Build the app for a generic iOS Simulator destination.** Passed with `rtk proxy xcodebuild ... -destination 'generic/platform=iOS Simulator'`; existing Swift concurrency/deprecation warnings remain.
- [x] **Step 2: Run focused layout, picker, summary, skill, and navigation tests on available simulator destinations, sequentially.**
- [x] **Step 3: Inspect the full diff against the approved design and check iPhone Summary, tabs, compact threshold, tile order, dynamic skill split, selector metadata, and deletion behavior.** `rtk git diff --check` passed. UI checks passed on iPad Pro 11-inch M4 (iOS 26.2), iPad Pro (iOS 27), and iPhone 18 Pro (iOS 27), as available in the simulator set.
- [x] **Step 4: Record actual test results and simulator limitations in this plan.** The two focused Swift Testing targets passed. UI tests passed for both tile orientations, landscape ordering and bounds, card contents/navigation, delete confirmation presentation, adaptive two-/one-column picker behavior, search state across rotation/compact layout, skill editing/check/delete, long-list and growing-note page scrolling, and iPhone tabs/Summary. Simulator startup/teardown emitted CoreSimulator/debugger warnings; no test assertion failures remain.
- [x] **Step 5: Review the task files and verify the worktree status.** Left the changes uncommitted on `codex/ipad-character-tiles`; no commit was requested.
