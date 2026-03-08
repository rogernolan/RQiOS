# Rune Edit Layout Stability Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Stabilize rune chip geometry when toggling between read-only and editing so titles, checkboxes, rune icons, and chip bounds stay visually fixed while the existing animation remains intact.

**Architecture:** Add a small shared layout-metrics type for rune chips, cover its invariants with unit tests, and update `RunesView` to use those metrics for both display and edit states. Remove the edit-only spacer that shifts the elemental ring downward.

**Tech Stack:** Swift 6.2, SwiftUI, Swift Testing, Xcode project tests

---

### Task 1: Add failing tests for layout invariants

**Files:**
- Create: `RQSheetTests/RuneChipLayoutMetricsTests.swift`
- Test: `RQSheetTests/RuneChipLayoutMetricsTests.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import RQSheet

struct RuneChipLayoutMetricsTests {
    @Test
    func percentageSlotWidthIsSharedAcrossModes() {
        #expect(RuneChipLayoutMetrics.percentageSlotWidth(for: false) == RuneChipLayoutMetrics.percentageSlotWidth(for: true))
    }

    @Test
    func checkboxSlotHasFixedVisibleWidth() {
        #expect(RuneChipLayoutMetrics.checkboxSlotWidth > 0)
    }

    @Test
    func editorInsetKeepsFieldOffChipEdge() {
        #expect(RuneChipLayoutMetrics.percentageEditorHorizontalInset > 0)
        #expect(RuneChipLayoutMetrics.percentageEditorWidth < RuneChipLayoutMetrics.percentageSlotWidth(for: true))
    }
}
```

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex/runes-edit-layout-stability/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=0D618A40-1A2D-49C7-BD62-4295D747E18E' -only-testing:RQSheetTests/RuneChipLayoutMetricsTests CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=''
```

Expected: FAIL because `RuneChipLayoutMetrics` and the test file do not exist yet.

**Step 3: Commit**

```bash
git add RQSheetTests/RuneChipLayoutMetricsTests.swift
git commit -m "test: add rune chip layout metric coverage"
```

### Task 2: Add shared rune chip layout metrics

**Files:**
- Create: `RQSheet/RuneChipLayoutMetrics.swift`
- Modify: `RQSheet/RunesView.swift`
- Test: `RQSheetTests/RuneChipLayoutMetricsTests.swift`

**Step 1: Write minimal implementation**

```swift
enum RuneChipLayoutMetrics {
    static let chipWidth: CGFloat = 97
    static let checkboxSlotWidth: CGFloat = 14
    static let percentageEditorWidth: CGFloat = 52
    static let percentageEditorHorizontalInset: CGFloat = 2

    static func percentageSlotWidth(for _: Bool) -> CGFloat {
        58
    }
}
```

**Step 2: Update the view to use shared metrics**

- apply `chipWidth` and shared padding values in `RunicAffinityNodeView`
- reserve `checkboxSlotWidth` for the checkbox button image
- use `percentageSlotWidth(for:)` for both display and edit mode
- use `percentageEditorHorizontalInset` to keep the editor off the chip edge
- remove the edit-only spacer from `RunicAffinitiesPentagramView`

**Step 3: Run test to verify it passes**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex/runes-edit-layout-stability/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=0D618A40-1A2D-49C7-BD62-4295D747E18E' -only-testing:RQSheetTests/RuneChipLayoutMetricsTests CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=''
```

Expected: PASS for `RuneChipLayoutMetricsTests`

**Step 4: Run broader verification**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex/runes-edit-layout-stability/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=0D618A40-1A2D-49C7-BD62-4295D747E18E' -only-testing:RQSheetTests CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=''
```

Expected: all unit tests pass, or any unrelated existing failures are identified clearly.

**Step 5: Commit**

```bash
git add RQSheet/RuneChipLayoutMetrics.swift RQSheet/RunesView.swift RQSheetTests/RuneChipLayoutMetricsTests.swift
git commit -m "fix: stabilize rune chip layout while editing"
```
