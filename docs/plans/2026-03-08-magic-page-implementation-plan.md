# Magic Page Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the Magic tab as a searchable two-section spell manager with Spirit Magic and Rune Spells, character-level magic/rune point controls, bottom-sheet add/edit flows, and swipe-to-delete.

**Architecture:** Add a shared `CharacterSpell` SwiftData model keyed by `SpellKind`, store magic-point and rune-point fields directly on `RQCharacter`, and implement the screen with a dedicated `MagicViewModel` modeled after the Equipment page. Keep UI behavior consistent with Equipment for grouping, search, edit sheets, and destructive delete confirmation.

**Tech Stack:** SwiftUI, SwiftData, XCTest UI tests, Swift Testing unit tests.

---

### Task 1: Add spell persistence model

**Files:**
- Create: `RQSheet/CharacterSpell.swift`
- Modify: `RQSheet/Character.swift`
- Modify: `RQSheet/RQSheetApp.swift`
- Modify: `RQSheet/ContentView.swift`
- Test: `RQSheetTests/CharacterMagicTests.swift`

**Step 1: Write the failing test**

Add `RQSheetTests/CharacterMagicTests.swift` with coverage for:
- default rune points is `3`
- default max magic points is `pow`
- default current magic points is clamped to max
- adding spells preserves increasing `sortOrder`
- spell points clamp to non-negative

Include tests like:

```swift
@Test
func magicDefaultsTrackPow() {
    let character = RQCharacter()
    #expect(character.runePoints == 3)
    #expect(character.maxMagicPoints == character.pow)
    #expect(character.currentMagicPoints == character.maxMagicPoints)
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/CharacterMagicTests
```

Expected: FAIL because `CharacterSpell`, `runePoints`, or magic-point properties do not exist.

**Step 3: Write minimal implementation**

Implement:
- `CharacterSpell` model with `name`, `points`, `page`, `kind`, `sortOrder`, `character`
- `SpellKind` enum with `spiritMagic` and `runeSpell`
- new `RQCharacter` properties: `spells`, `currentMagicPoints`, `maxMagicPoints`, `runePoints`
- helper `addSpell(...)`
- clamping rules for `points`, `runePoints`, `currentMagicPoints`
- schema wiring in app and preview model containers

**Step 4: Run test to verify it passes**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/CharacterMagicTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page add RQSheet/CharacterSpell.swift RQSheet/Character.swift RQSheet/RQSheetApp.swift RQSheet/ContentView.swift RQSheetTests/CharacterMagicTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page commit -m "feat(magic): add spell persistence model"
```

### Task 2: Recalculate magic points from POW

**Files:**
- Modify: `RQSheet/Character.swift`
- Test: `RQSheetTests/CharacterMagicTests.swift`

**Step 1: Write the failing test**

Extend `CharacterMagicTests` with cases for:
- reducing `pow` recalculates `maxMagicPoints`
- `currentMagicPoints` clamps down when new max is lower
- increasing `pow` increases `maxMagicPoints` without forcing `currentMagicPoints` upward

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/CharacterMagicTests
```

Expected: FAIL because POW changes do not yet recalculate magic points.

**Step 3: Write minimal implementation**

Update `RQCharacter` so:
- `pow` has a `didSet` that recalculates `maxMagicPoints`
- recalculation clamps `currentMagicPoints` into `0...maxMagicPoints`
- initialization still behaves correctly when random defaults are assigned

**Step 4: Run test to verify it passes**

Run the same command.

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page add RQSheet/Character.swift RQSheetTests/CharacterMagicTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page commit -m "feat(magic): recalculate magic points from pow"
```

### Task 3: Add view-model support for grouped spells and search

**Files:**
- Create: `RQSheet/MagicViewModel.swift`
- Test: `RQSheetTests/MagicViewModelTests.swift`

**Step 1: Write the failing test**

Create `MagicViewModelTests.swift` covering:
- spirit and rune spells grouped correctly
- search ranks `name` matches before `page` matches
- insertion order preserved within each rank and section
- header text/derived values expose expected current/max and casting percent
- delete pending state behaves like equipment

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/MagicViewModelTests
```

Expected: FAIL because `MagicViewModel` does not exist.

**Step 3: Write minimal implementation**

Implement `MagicViewModel` with:
- `searchText`
- `pendingDeleteSpell`
- `visibleSpiritSpells`
- `visibleRuneSpells`
- `spiritCastingPercentageText`
- `magicPointsText`
- `runePointsText`
- `isSpiritSectionEmptyStateSearchResult` / `isRuneSectionEmptyStateSearchResult` if needed for clean view logic
- add/edit/delete helpers
- update helpers for current magic points and rune points

**Step 4: Run test to verify it passes**

Run the same command.

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page add RQSheet/MagicViewModel.swift RQSheetTests/MagicViewModelTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page commit -m "feat(magic): add grouped spell view model"
```

### Task 4: Add reusable spell editor sheet

**Files:**
- Create: `RQSheet/SpellEditorView.swift`
- Test: `RQSheetTests/SpellEditorViewTests.swift`

**Step 1: Write the failing test**

Create tests that assert the source contains:
- `NavigationStack`
- `Form`
- fields for `Name`, `Points`, `Page`
- explicit cancellation and confirmation toolbar items
- editor can be initialized in add and edit modes

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/SpellEditorViewTests
```

Expected: FAIL because `SpellEditorView` does not exist.

**Step 3: Write minimal implementation**

Implement a shared sheet editor with:
- `title`
- `name`
- `points`
- `page`
- `onSave`
- `Cancel` / `Save`
- integer parsing/clamping for points

**Step 4: Run test to verify it passes**

Run the same command.

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page add RQSheet/SpellEditorView.swift RQSheetTests/SpellEditorViewTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page commit -m "feat(magic): add spell editor sheet"
```

### Task 5: Replace the Magic placeholder with the real screen

**Files:**
- Modify: `RQSheet/MagicView.swift`
- Test: `RQSheetTests/MagicViewTests.swift`

**Step 1: Write the failing test**

Create tests that assert:
- page no longer contains `Magic placeholder`
- page does not declare its own `NavigationStack`
- page includes a search field
- page contains both section titles
- page includes add buttons and delete alert text

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/MagicViewTests
```

Expected: FAIL because `MagicView` is still a placeholder.

**Step 3: Write minimal implementation**

Implement `MagicView` using the Equipment page structure:
- overlay header with `Magic`
- shared search bar
- two sections in one scrolling list: Spirit Magic and Rune Spells
- translucent spell cards
- inline editable Spirit Magic current/max magic points control
- inline editable Rune Points control
- add-sheet state for each spell kind
- row tap to edit
- swipe-to-delete with confirmation
- section-local empty states

**Step 4: Run test to verify it passes**

Run the same command.

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page add RQSheet/MagicView.swift RQSheetTests/MagicViewTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page commit -m "feat(magic): implement grouped magic page"
```

### Task 6: Add targeted UI coverage for the magic flow

**Files:**
- Modify: `RQSheetUITests/RQSheetUITests.swift`

**Step 1: Write the failing test**

Add UI tests for:
- opening the Magic tab
- Spirit Magic add button presents `Add Spirit Magic`
- Rune Spells add button presents `Add Rune Spell`
- saving a spell creates a visible row
- tapping a row presents the edit sheet
- search filters rows by name and page

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetUITests/testMagicAddSpiritSpellPresentsSheet -only-testing:RQSheetUITests/testMagicAddRuneSpellPresentsSheet -only-testing:RQSheetUITests/testMagicRowCanBeTappedToEdit -only-testing:RQSheetUITests/testMagicSearchFiltersByNameAndPage
```

Expected: FAIL until the new identifiers and flows are implemented.

**Step 3: Write minimal implementation**

Add any missing accessibility identifiers or minor view adjustments required to make the tests reliable.

**Step 4: Run test to verify it passes**

Run the same command.

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page add RQSheetUITests/RQSheetUITests.swift RQSheet/MagicView.swift
Git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page commit -m "test(magic): cover add edit and search flows"
```

### Task 7: Run full verification and clean up

**Files:**
- Modify: any files needed from previous tasks

**Step 1: Run focused test suites**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/CharacterMagicTests -only-testing:RQSheetTests/MagicViewModelTests -only-testing:RQSheetTests/SpellEditorViewTests -only-testing:RQSheetTests/MagicViewTests -only-testing:RQSheetUITests/testMagicAddSpiritSpellPresentsSheet -only-testing:RQSheetUITests/testMagicAddRuneSpellPresentsSheet -only-testing:RQSheetUITests/testMagicRowCanBeTappedToEdit -only-testing:RQSheetUITests/testMagicSearchFiltersByNameAndPage
```

Expected: PASS.

**Step 2: Run app build**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-magic-page/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: BUILD SUCCEEDED.

**Step 3: Check git status**

Run:
```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page status --short
```

Expected: only intended modified files remain.

**Step 4: Commit final cleanup**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page add RQSheet RQSheetTests RQSheetUITests
git -C /Users/rog/Development/RQSheet/.worktrees/codex-magic-page commit -m "feat(magic): finalize magic page"
```
