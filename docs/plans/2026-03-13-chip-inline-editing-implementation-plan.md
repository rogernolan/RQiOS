# Chip Inline Editing Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Bring the inline-editable chip behavior with editable marker, green completion button, and keyboard-aware scrolling to runes, combat HP, and magic MP/RP.

**Architecture:** Add one shared chip-value editor that supports both single-value and current-of-max display modes. Integrate it into `RunesView`, `CombatView`, and `MagicView`, while each screen owns its active editing state and scroll-to-visible behavior.

**Tech Stack:** SwiftUI, Swift Testing, source-level view regression tests, existing model bindings in `RQCharacter`, `RuneAffinity`, and combat/magic screen view state.

---

## Follow-up Scope

This pass tightens the first chip-editing implementation:

- remove the rune workspace edit toggle
- make rune chips always individually editable
- move the editable marker into the rune chip title row
- hide `%` while a rune value is actively editing
- stabilize combat HP chip width across display/edit states
- enlarge idle MP/RP chips so text fits without clipping
- lower the magic scroll target so edited chips stop below the search bar
- slightly increase the elemental pentagram radius if the larger rune value region needs more clearance

This follow-up also adds animation polish to the shared editor:

- animate the completion button in with a spring overshoot from `25%` scale / `25%` opacity to `110%`, then settle at `100%`
- animate the text field/value region left while editing to create real space for the button
- animate the button away and the display value plus suffix back into place when editing completes
- prevent the completion button path from triggering a second parent scroll jump

### Task 1: Add shared regression coverage for the new chip behavior

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/CombatViewTests.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/RuneChipLayoutMetricsTests.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/MagicViewTests.swift` or create if missing
- Create: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/EditableChipValueTests.swift`

**Step 1: Write the failing tests**

- Assert a shared editable chip value component exists.
- Assert it includes the editable marker and a green completion control.
- Assert `CombatView` uses a split-value chip for HP rather than a raw top-level `TextField`.
- Assert `MagicView` uses shared chip editing for MP and RP.
- Assert rune chip layout still reserves stable width/height while editing.
- Assert rune chips are individually editable without a workspace-level edit toggle.
- Assert the rune marker is rendered in the title row rather than as a top-trailing overlay.
- Assert the `%` suffix is hidden while actively editing a single-value chip.
- Assert magic chip scrolling targets a safe anchor below the search overlay.

**Step 2: Run test to verify it fails**

Run:
`xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet.xcodeproj -scheme RQSheet -destination 'id=00006000-001810893A62801E' -only-testing:RQSheetTests/EditableChipValueTests -only-testing:RQSheetTests/CombatViewTests -only-testing:RQSheetTests/RuneChipLayoutMetricsTests -only-testing:RQSheetTests/MagicViewTests`

Expected:
- Failing assertions for missing shared chip editor references and missing source strings.

**Step 3: Write minimal implementation-independent test helpers**

- Add or extend source-reading helpers only as needed.
- Keep tests focused on observable source structure, not speculative implementation details.

**Step 4: Run test to verify it still fails for the intended reasons**

Run the same command and confirm failures are about the missing feature, not broken test plumbing.

**Step 5: Commit**

```bash
git add RQSheetTests/CombatViewTests.swift RQSheetTests/RuneChipLayoutMetricsTests.swift RQSheetTests/MagicViewTests.swift RQSheetTests/EditableChipValueTests.swift
git commit -m "test: cover inline editable chip behavior"
```

### Task 2: Add the shared editable chip value component

**Files:**
- Create: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/EditableChipValue.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/RuneChipLayoutMetrics.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/EditableChipValueTests.swift`

**Step 1: Write the failing test**

- Add targeted assertions for:
  - `singleValue` mode
  - `currentOfMax` mode
  - editable marker presence
  - green completion button presence
  - stable sizing hooks exposed for chip integrations

**Step 2: Run test to verify it fails**

Run:
`xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet.xcodeproj -scheme RQSheet -destination 'id=00006000-001810893A62801E' -only-testing:RQSheetTests/EditableChipValueTests`

Expected:
- Fail because the component and/or expected source hooks do not exist yet.

**Step 3: Write minimal implementation**

- Add `EditableChipValue` with:
  - `singleValue`
  - `currentOfMax`
  - active editing state
  - marker rendering
  - green animated completion button
  - integer-only input handling
  - explicit layout hooks for marker, value, suffix, and completion width so idle/edit states can share a stable footprint

**Step 4: Run test to verify it passes**

Run the same command and confirm the component coverage passes.

**Step 5: Commit**

```bash
git add RQSheet/EditableChipValue.swift RQSheet/RuneChipLayoutMetrics.swift RQSheetTests/EditableChipValueTests.swift
git commit -m "feat: add shared editable chip value"
```

### Task 3: Integrate shared editing into rune chips

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/RunesView.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/RuneChipLayoutMetrics.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/RuneChipLayoutMetricsTests.swift`

**Step 1: Write the failing test**

- Assert `RunesView` uses the shared editable chip value instead of the old inline percentage `TextField` layout.
- Assert the layout metrics still keep editing width/height stable.

**Step 2: Run test to verify it fails**

Run:
`xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet.xcodeproj -scheme RQSheet -destination 'id=00006000-001810893A62801E' -only-testing:RQSheetTests/RuneChipLayoutMetricsTests`

Expected:
- Fail until `RunesView` is rewired.

**Step 3: Write minimal implementation**

- Replace the rune percentage region with the shared component in `singleValue` mode.
- Preserve current experience check, rune label, and icon placement.
- Remove reliance on a workspace-level rune edit toggle.
- Move the marker into the chip title row.
- Hide `%` while the field is actively editing.
- If needed, increase the elemental pentagram radius slightly to keep larger chips from colliding.
- Track active editing chip at the rune screen level for keyboard-aware scrolling.

**Step 4: Run test to verify it passes**

Run the same command and confirm rune chip regression tests pass.

**Step 5: Commit**

```bash
git add RQSheet/RunesView.swift RQSheet/RuneChipLayoutMetrics.swift RQSheetTests/RuneChipLayoutMetricsTests.swift
git commit -m "feat: add inline editing to rune chips"
```

### Task 4: Integrate shared editing into combat HP chip

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/CombatView.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

- Assert combat HP uses the shared split-value chip.
- Assert the max HP suffix remains read-only display content.

**Step 2: Run test to verify it fails**

Run:
`xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet.xcodeproj -scheme RQSheet -destination 'id=00006000-001810893A62801E' -only-testing:RQSheetTests/CombatViewTests`

Expected:
- Fail until the HP chip implementation changes.

**Step 3: Write minimal implementation**

- Replace the raw HP `TextField` logic with the shared component in `currentOfMax` mode.
- Keep current HP clamping/sync behavior intact.
- Reserve enough chip width for both idle and editing states.
- Add combat-screen keyboard-aware scrolling for the active chip.

**Step 4: Run test to verify it passes**

Run the same command and confirm combat tests pass.

**Step 5: Commit**

```bash
git add RQSheet/CombatView.swift RQSheetTests/CombatViewTests.swift
git commit -m "feat: add inline editing to combat hp chip"
```

### Task 5: Integrate shared editing into magic MP and RP chips

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/MagicView.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/MagicViewTests.swift`

**Step 1: Write the failing test**

- Assert MP uses `currentOfMax` mode.
- Assert RP uses `singleValue` mode.
- Assert the old standalone raw chip editors are removed.

**Step 2: Run test to verify it fails**

Run:
`xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet.xcodeproj -scheme RQSheet -destination 'id=00006000-001810893A62801E' -only-testing:RQSheetTests/MagicViewTests`

Expected:
- Fail until `MagicView` is rewired.

**Step 3: Write minimal implementation**

- Replace `MagicPointsEditor` and `RunePointsEditor` internals with the shared component.
- Preserve existing labels and chip chrome.
- Reserve enough idle width for `MP current/max` and `RP current`.
- Add magic-screen keyboard-aware scrolling for the active chip using an anchor that stops below the search bar.

**Step 4: Run test to verify it passes**

Run the same command and confirm magic tests pass.

**Step 5: Commit**

```bash
git add RQSheet/MagicView.swift RQSheetTests/MagicViewTests.swift
git commit -m "feat: add inline editing to magic point chips"
```

### Task 6: Run focused verification and final cleanup

**Files:**
- Verify only

**Step 1: Run focused unit verification**

Run:
`xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet.xcodeproj -scheme RQSheet -destination 'id=00006000-001810893A62801E' -only-testing:RQSheetTests/EditableChipValueTests -only-testing:RQSheetTests/RuneChipLayoutMetricsTests -only-testing:RQSheetTests/CombatViewTests -only-testing:RQSheetTests/MagicViewTests`

Expected:
- All focused chip-editing tests pass.

**Step 2: Run broader unit verification if harness allows**

Run:
`xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet.xcodeproj -scheme RQSheet -destination 'id=00006000-001810893A62801E' -only-testing:RQSheetTests`

Expected:
- Full unit target passes, or document any pre-existing harness limitation if it stalls again.

**Step 3: Review diff**

Run:
`git status --short && git diff --stat`

Expected:
- Only intended chip-editing files changed.

### Task 7: Add completion-button animation and no-rescroll behavior

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/EditableChipValue.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/RunesView.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/CombatView.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet/MagicView.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/EditableChipValueTests.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/MagicViewTests.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/CombatViewTests.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheetTests/RuneChipLayoutMetricsTests.swift`

**Step 1: Write the failing tests**

- Assert `EditableChipValue` contains explicit animation hooks for:
  - button start scale `0.25`
  - button overshoot scale near `1.1`
  - opacity transition from `0.25` to full
  - animated value-offset/layout change while editing
- Assert the completion path is distinct from generic focus loss so screens can avoid rescrolling on button tap.
- Assert the parent screens do not directly scroll on `onEndEditing` or any completion callback.

**Step 2: Run test to verify it fails**

Run:
`xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-chip-editing/RQSheet.xcodeproj -scheme RQSheet -destination 'id=00006000-001810893A62801E' -only-testing:RQSheetTests/EditableChipValueTests -only-testing:RQSheetTests/MagicViewTests -only-testing:RQSheetTests/CombatViewTests -only-testing:RQSheetTests/RuneChipLayoutMetricsTests`

Expected:
- Fail because the shared editor lacks the new animation constants and completion handling.

**Step 3: Write minimal implementation**

- Add a dedicated animated completion-button phase in `EditableChipValue`.
- Keep the button center fixed at its final location while scale/opacity animate.
- Animate the value/text-field region horizontally to make space for the button.
- Add a completion callback path that lets parent screens clear editor state without re-triggering a scroll.
- Update the chip-owning screens only as needed to use the non-rescrolling completion callback.

**Step 4: Run test to verify it passes**

Run the same command and confirm the animation/source regression tests pass.

**Step 5: Commit**

```bash
git add RQSheet/EditableChipValue.swift RQSheet/RunesView.swift RQSheet/CombatView.swift RQSheet/MagicView.swift RQSheetTests/EditableChipValueTests.swift RQSheetTests/MagicViewTests.swift RQSheetTests/CombatViewTests.swift RQSheetTests/RuneChipLayoutMetricsTests.swift
git commit -m "feat: animate inline chip completion"
```

**Step 4: Commit**

```bash
git add .
git commit -m "feat: add inline editing to rune combat and magic chips"
```
