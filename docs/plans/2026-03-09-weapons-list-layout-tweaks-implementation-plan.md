# Weapons List Layout Tweaks Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Tighten the weapons row layout, widen the usable list area, switch the disclosure affordance to a down-pointing outlined/filled triangle, and make row expansion animate in place without surrounding rows snapping.

**Architecture:** Keep the existing `List` and `WeaponRowCard` structure in `CombatView.swift`. Limit changes to row inset constants, compact row geometry, disclosure icon rendering, and expansion/collapse animation structure so swipe-to-delete and editing behavior remain unchanged.

**Tech Stack:** SwiftUI, Swift Testing, Xcode unit test target

---

### Task 1: Lock the requested layout and animation structure in tests

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Add a source-level test asserting:
- row insets use narrower leading/trailing values than `16`
- compact row widths are tightened for `%`, experience, and `SR`
- the disclosure icon uses a down triangle in both states
- the expanded section no longer uses `.transition(.move(edge: .top).combined(with: .opacity))`

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests`
Expected: FAIL in the new layout/animation test

**Step 3: Write minimal implementation**

Update the `CombatView` row layout and expansion code only enough to satisfy the new assertions.

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests`
Expected: PASS

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "refactor: tighten weapons row layout"
```

### Task 2: Implement the in-place expansion behavior

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Extend the source-level assertions, if needed, so they explicitly check that the detail block stays structurally present and animates via opacity/frame-based behavior instead of insertion/removal transition.

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests`
Expected: FAIL because the old transition is still present or the new structure is missing

**Step 3: Write minimal implementation**

Keep the detail content inside the card and animate visibility/height while the row remains in place.

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests`
Expected: PASS

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "fix: smooth weapon row expansion"
```

### Task 3: Run regression verification

**Files:**
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CharacterEquipmentTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/EquipmentViewModelTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/SummaryViewModelTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/SummaryPersistenceIntegrationTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/WeaponSkillTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/WeaponEditorViewTests.swift`

**Step 1: Run regression suite**

Run:

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

Expected: PASS

**Step 2: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "test: cover weapon layout tweaks"
```
