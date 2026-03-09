# Combat Header And Weapon Layout Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refine the Combat screen header and weapon rows with inline HP editing, derived damage bonus, a softer scroll/header transition, better SR alignment, and fixed-position expanded detail rows.

**Architecture:** Keep the current `ScrollView`/`LazyVStack` weapons stack, add a dedicated combat header row above it, and derive display values from `RQCharacter` or `SummaryViewModel` helpers rather than embedding rules in the view. Preserve the working row expansion behavior by changing row layout only inside the card, not by reintroducing `List` or overlay-based measurement.

**Tech Stack:** SwiftUI, SwiftData, Swift Testing, existing source-level view tests

---

### Task 1: Lock In The New Combat Header And Row Expectations

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Add expectations for:

- no `Text("Total Hitpoints:`
- a dedicated combat header row helper
- `HP` chip and `Damage Bonus` chip labels
- a top gradient/overlay handoff
- a fixed-width SR column sized for longer values
- fixed-position expanded detail rows

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests
```

Expected: `CombatViewTests` fails because the current source still contains the old combat header and flexible expanded-detail structure.

**Step 3: Write minimal implementation**

Do not implement production code yet. Adjust only the test file until the failure clearly targets the new requirements.

**Step 4: Run test to verify it fails**

Run the same command again and confirm the relevant combat header/layout expectations are failing.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "test: cover combat header and row layout refinements"
```

### Task 2: Add Damage Bonus Derivation

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/Character.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/SummaryViewModel.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/SummaryViewModelTests.swift`

**Step 1: Write the failing test**

Add tests for several `STR + SIZ` bands:

- `12` -> `-1D4`
- `24` -> `-`
- `25` -> `+1D4`
- `33` -> `+1D6`
- `41` -> `+2D6`
- `57` -> `+3D6`

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SummaryViewModelTests
```

Expected: failure because no damage bonus text helper exists yet.

**Step 3: Write minimal implementation**

Add a helper on `RQCharacter` or `SummaryViewModel` that returns a display string from `str + siz`, then expose it for Combat and Summary usage.

**Step 4: Run test to verify it passes**

Run the same command and confirm the new damage bonus expectations pass.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/Character.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/SummaryViewModel.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/SummaryViewModelTests.swift
git commit -m "feat: derive damage bonus from strength and size"
```

### Task 3: Build The Combat Header Chips

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Expand the combat source test to require:

- a combat header chip row helper
- inline integer HP editing
- a `Damage Bonus` chip bound to the derived helper
- removal of the old centered total-hitpoints text

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests
```

Expected: failure because `CombatView` still uses the old text-only header.

**Step 3: Write minimal implementation**

Implement:

- a top combat header row
- a translucent left `HP` chip with an integer `TextField` for current HP and a static `/max`
- a translucent right `Damage Bonus` chip
- bindings that keep the HP field synchronized with clamped model values

**Step 4: Run test to verify it passes**

Run the same command and confirm the new header expectations pass.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "feat: add combat header chips"
```

### Task 4: Soften The Scroll/Header Transition

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Require a gradient-based top handoff in the combat weapons section.

**Step 2: Run test to verify it fails**

Run the focused combat test command and confirm the new gradient expectation fails.

**Step 3: Write minimal implementation**

Add a top gradient mask or overlay so the weapon cards fade under the header instead of disappearing behind a hard cutoff.

**Step 4: Run test to verify it passes**

Run the focused combat test command again and confirm it passes.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "feat: soften combat list header transition"
```

### Task 5: Fix Compact Weapon Row Column Alignment

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Add expectations for:

- fixed-width experience checkbox column
- fixed-width SR column sized for values like `SR 2/8`
- tighter SR-to-damage spacing

**Step 2: Run test to verify it fails**

Run the focused combat test command and confirm the compact-row layout expectations fail.

**Step 3: Write minimal implementation**

Adjust the compact row widths and spacing so:

- checkbox alignment stays constant across all rows
- longer SR values fit without shifting neighboring columns
- damage remains aligned on the right

**Step 4: Run test to verify it passes**

Run the focused combat test command again and confirm it passes.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "fix: align combat weapon row columns"
```

### Task 6: Make Expanded Detail Layout Stable

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Add expectations for:

- larger expanded-detail text
- fixed slots for `HP`, `ENC`, `Type`, `Equipped`
- `Range` rendered in the last slot on the second row when present
- no label rendered for absent range values

**Step 2: Run test to verify it fails**

Run the focused combat test command and confirm the expanded-layout expectations fail.

**Step 3: Write minimal implementation**

Refactor the expanded section into fixed slot rows rather than free-flowing chips, keeping the current height animation and delayed text fade.

**Step 4: Run test to verify it passes**

Run the focused combat test command again and confirm it passes.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "feat: stabilize combat weapon detail layout"
```

### Task 7: Run Regression Verification

**Files:**
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CharacterEquipmentTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/EquipmentViewModelTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/SummaryViewModelTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/SummaryPersistenceIntegrationTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/WeaponSkillTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/WeaponEditorViewTests.swift`

**Step 1: Run the regression slice**

```bash
xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:RQSheetTests/CharacterEquipmentTests \
  -only-testing:RQSheetTests/EquipmentViewModelTests \
  -only-testing:RQSheetTests/SummaryViewModelTests \
  -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests \
  -only-testing:RQSheetTests/CombatViewTests \
  -only-testing:RQSheetTests/WeaponSkillTests \
  -only-testing:RQSheetTests/WeaponEditorViewTests
```

Expected: all targeted tests pass.

**Step 2: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests
git commit -m "feat: polish combat header and weapon layout"
```
