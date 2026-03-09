# Weapons Row Animation Sequencing Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make each weapon row expand as one clipped card that grows first and then reveals detail content, without the current jumpy second-card effect.

**Architecture:** Limit the change to `WeaponRowCard` inside `CombatView.swift`. Replace the existing whole-card animation binding with explicit detail-height measurement and separate detail-opacity control, while keeping the current `List` structure and disclosure state model.

**Tech Stack:** SwiftUI, Swift Testing, Xcode unit test target

---

### Task 1: Lock the new animation structure in tests

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Add a source-level test asserting:
- `WeaponRowCard` stores explicit detail height and detail opacity state
- the visible detail container uses a clipped explicit height frame
- expand/collapse is handled with `onChange(of: isExpanded)` or equivalent explicit logic
- the previous `.animation(.easeInOut(duration: 0.2), value: isExpanded)` binding is removed

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests`
Expected: FAIL in the new animation-structure test

**Step 3: Write minimal implementation**

Update `WeaponRowCard` so height and opacity are controlled separately, using the smallest amount of new state and measurement code needed.

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -quiet -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests`
Expected: PASS

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "fix: sequence weapon row expansion"
```

### Task 2: Verify the broader regression slice

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
git commit -m "test: verify weapon row animation sequencing"
```
