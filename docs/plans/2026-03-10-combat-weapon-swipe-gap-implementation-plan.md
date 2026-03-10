# Combat Weapon Swipe Gap Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update Combat weapon swipe-to-delete so the revealed row rests with a 15-point gap to the delete pill, and the pill only translates during overdrag with a 10-point cap.

**Architecture:** Keep the current SwiftUI `WeaponSwipeRow` drag architecture. Change the swipe math only: separate row resting offset from pill translation, and derive pill motion exclusively from overdrag beyond the revealed resting position.

**Tech Stack:** SwiftUI, Swift Testing, Xcode/iOS Simulator

---

### Task 1: Add a failing regression test for swipe spacing math

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/SwipeDirectionLockTests.swift`

**Step 1: Write the failing test**

Add tests for pure swipe math helpers that assert:

- revealed row offset includes an extra `15pt` gap
- pill offset is `0` until overdrag starts
- pill overdrag caps at `10pt`

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -quiet -project /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:RQSheetTests/SwipeDirectionLockTests
```

Expected: FAIL because the helper does not exist or current math does not match.

**Step 3: Write minimal implementation**

Add a small swipe-math helper in `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift` for:

- revealed row resting offset
- delete progress during reveal
- pill overdrag offset

**Step 4: Run test to verify it passes**

Run the same command and confirm the new tests pass.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/SwipeDirectionLockTests.swift
git commit -m "test: cover combat swipe gap math"
```

### Task 2: Apply the swipe motion changes in the Combat row

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Update source assertions to require:

- explicit `15` point reveal gap constant
- explicit `10` point pill overdrag cap
- pill offset derived from overdrag beyond revealed resting offset

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -quiet -project /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:RQSheetTests/CombatViewTests
```

Expected: FAIL because the current swipe row still uses the older reveal math.

**Step 3: Write minimal implementation**

Change `WeaponSwipeRow` so:

- revealed resting row offset includes the extra gap
- pill translation stays at `0` during reveal
- pill translation begins only in overdrag
- pill overdrag is capped at `10pt`
- spring-back returns to the revealed resting offset

**Step 4: Run test to verify it passes**

Run the focused Combat test command again and confirm pass.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet/CombatView.swift /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheetTests/CombatViewTests.swift
git commit -m "fix: refine combat swipe reveal motion"
```

### Task 3: Run regression verification

**Files:**
- No file changes required

**Step 1: Run focused regression slice**

```bash
xcodebuild test -quiet -project /Users/rog/Development/RQSheet/.worktrees/codex-weapons-list-redesign/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:RQSheetTests/CharacterEquipmentTests \
  -only-testing:RQSheetTests/EquipmentViewModelTests \
  -only-testing:RQSheetTests/SummaryViewModelTests \
  -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests \
  -only-testing:RQSheetTests/CombatViewTests \
  -only-testing:RQSheetTests/WeaponSkillTests \
  -only-testing:RQSheetTests/WeaponEditorViewTests \
  -only-testing:RQSheetTests/SwipeDirectionLockTests
```

Expected: PASS

**Step 2: Verify live simulator behavior if available**

- Launch the app in Simulator
- Open Combat
- Swipe a weapon row
- Confirm the row rests with a visible gap, the pill only translates in overdrag, and release springs back to the gapped resting position

**Step 3: Commit**

```bash
git status --short
```

Confirm only intended files remain changed before final commit or follow-up.
