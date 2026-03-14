# Source-Reading Tests Cleanup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace chip-related source-reading XCTest patterns with behavior- and metric-based tests that run on iOS destinations without sandbox file-access failures.

**Architecture:** Move assertions away from `String(contentsOf:)` against repo paths and onto directly testable helpers, constants, and formatting behavior. Keep the pass narrowly scoped to the chip-related suites first, then verify those suites on the simulator destination used elsewhere in the project.

**Tech Stack:** Swift, Swift Testing, SwiftUI, XCTest via `xcodebuild`

---

### Task 1: Baseline The Failing Test Pattern

**Files:**
- Inspect: `/Users/rog/Development/RQSheet/RQSheetTests/EditableChipValueTests.swift`
- Inspect: `/Users/rog/Development/RQSheet/RQSheetTests/CombatViewTests.swift`
- Inspect: `/Users/rog/Development/RQSheet/RQSheetTests/MagicViewTests.swift`
- Inspect: `/Users/rog/Development/RQSheet/RQSheetTests/RuneChipLayoutMetricsTests.swift`

**Step 1: Run the failing focused test command**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet \
  -destination 'id=00006000-001810893A62801E' \
  -only-testing:RQSheetTests/RuneChipLayoutMetricsTests \
  -only-testing:RQSheetTests/EditableChipValueTests \
  -only-testing:RQSheetTests/CombatViewTests \
  -only-testing:RQSheetTests/MagicViewTests
```

Expected:
- failures include `NSCocoaErrorDomain Code=257`
- failures point at repo file reads

**Step 2: Record which assertions are structural versus behavioral**

Create a short working list:
- structural source-string assertions
- tests that already hit runtime helpers/constants

**Step 3: Commit nothing yet**

This task is baseline only.

---

### Task 2: Replace EditableChipValue Source Reads

**Files:**
- Modify: `/Users/rog/Development/RQSheet/RQSheet/EditableChipValue.swift`
- Modify: `/Users/rog/Development/RQSheet/RQSheetTests/EditableChipValueTests.swift`

**Step 1: Write the failing test**

Replace one current source-reading assertion with a direct helper/config assertion, for example:
- accessory width policy
- animation constants
- value shift/travel configuration

Expected initial result:
- test fails because the helper/config surface does not yet exist

**Step 2: Run the focused test to verify red**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet \
  -destination 'id=00006000-001810893A62801E' \
  -only-testing:RQSheetTests/EditableChipValueTests
```

Expected:
- the new test fails for the missing/existing mismatch reason, not a sandbox file read

**Step 3: Add the minimal product/test surface**

Implement the smallest internal helper/constants needed for the test to observe:
- accessory slot width behavior
- animation constant values
- mode/config rules

**Step 4: Remove the corresponding source-reading path**

Delete the `String(contentsOf:)` dependency from the converted tests.

**Step 5: Re-run the focused suite**

Expected:
- `EditableChipValueTests` passes
- no `Code=257` in that suite

**Step 6: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/EditableChipValue.swift \
        /Users/rog/Development/RQSheet/RQSheetTests/EditableChipValueTests.swift
git commit -m "test: replace editable chip source-reading checks"
```

---

### Task 3: Replace Rune View Structural Source Reads

**Files:**
- Modify: `/Users/rog/Development/RQSheet/RQSheet/RunesView.swift`
- Modify: `/Users/rog/Development/RQSheet/RQSheet/RuneChipLayoutMetrics.swift`
- Modify: `/Users/rog/Development/RQSheet/RQSheetTests/RuneChipLayoutMetricsTests.swift`

**Step 1: Write the failing test**

Convert the remaining `RunesView.swift` source-read assertions into direct checks on testable configuration:
- paired layout configuration
- top inset configuration

**Step 2: Run the focused suite to verify red**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet \
  -destination 'id=00006000-001810893A62801E' \
  -only-testing:RQSheetTests/RuneChipLayoutMetricsTests
```

**Step 3: Add minimal configuration hooks if needed**

Expose only the smallest constants/helpers required.

**Step 4: Remove the repo file read helper**

Delete the `runesViewSource()` path if no longer needed.

**Step 5: Re-run the suite**

Expected:
- suite passes
- no sandbox file-access failure

**Step 6: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/RunesView.swift \
        /Users/rog/Development/RQSheet/RQSheet/RuneChipLayoutMetrics.swift \
        /Users/rog/Development/RQSheet/RQSheetTests/RuneChipLayoutMetricsTests.swift
git commit -m "test: replace rune view source-reading checks"
```

---

### Task 4: Convert MagicView Tests To Helpers And Formatting Checks

**Files:**
- Modify: `/Users/rog/Development/RQSheet/RQSheet/MagicView.swift`
- Modify: `/Users/rog/Development/RQSheet/RQSheetTests/MagicViewTests.swift`

**Step 1: Write failing tests for direct observation**

Move assertions onto:
- scroll anchor constant/helper
- chip width constants/config
- formatting helpers for spell points/page labels where applicable

**Step 2: Run the suite to verify red**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet \
  -destination 'id=00006000-001810893A62801E' \
  -only-testing:RQSheetTests/MagicViewTests
```

**Step 3: Implement minimal helper extraction**

Do not refactor the whole view. Extract only what is needed for testability.

**Step 4: Remove direct source loading**

Delete `magicViewSource()` and replace string assertions with direct checks.

**Step 5: Re-run the suite**

Expected:
- suite passes
- no `Code=257`

**Step 6: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/MagicView.swift \
        /Users/rog/Development/RQSheet/RQSheetTests/MagicViewTests.swift
git commit -m "test: replace magic view source-reading checks"
```

---

### Task 5: Reduce CombatView Tests To Real Behavioral Assertions

**Files:**
- Modify: `/Users/rog/Development/RQSheet/RQSheet/CombatView.swift`
- Modify: `/Users/rog/Development/RQSheet/RQSheetTests/CombatViewTests.swift`

**Step 1: Split structural from behavioral checks**

Keep:
- formatting helpers
- explicit value/display behavior

Replace/remove:
- source-string checks for exact view composition
- source-string checks for exact modifier presence

**Step 2: Write failing direct tests**

Add tests around helpers/constants that matter instead of text inspection.

**Step 3: Run the suite to verify red**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet \
  -destination 'id=00006000-001810893A62801E' \
  -only-testing:RQSheetTests/CombatViewTests
```

**Step 4: Implement the smallest supporting changes**

Extract narrowly scoped helpers/config only if required.

**Step 5: Remove direct repo reads**

Delete `combatViewSource()` and remaining file reads in that suite.

**Step 6: Re-run the suite**

Expected:
- suite passes
- no sandbox file-access failure

**Step 7: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/CombatView.swift \
        /Users/rog/Development/RQSheet/RQSheetTests/CombatViewTests.swift
git commit -m "test: replace combat view source-reading checks"
```

---

### Task 6: Run Combined Verification

**Files:**
- Verify only

**Step 1: Run the focused combined suites**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet \
  -destination 'id=00006000-001810893A62801E' \
  -only-testing:RQSheetTests/RuneChipLayoutMetricsTests \
  -only-testing:RQSheetTests/EditableChipValueTests \
  -only-testing:RQSheetTests/CombatViewTests \
  -only-testing:RQSheetTests/MagicViewTests
```

Expected:
- all four suites pass
- no `NSCocoaErrorDomain Code=257`

**Step 2: Run a merged app build**

Run:

```bash
xcodebuild build -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet \
  -destination 'id=00006000-001810893A62801E'
```

Expected:
- `** BUILD SUCCEEDED **`

**Step 3: Commit any final cleanup**

```bash
git add -A
git commit -m "test: clean up chip source-reading suites"
```

If there is nothing left to commit, do not create an empty commit.
