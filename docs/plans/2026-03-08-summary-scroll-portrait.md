# Summary Scroll Portrait Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a scroll-driven Summary hero portrait section that expands on load and collapses into the current compact identity layout while preserving the existing edit affordances.

**Architecture:** `StatsOverviewView` will own a single scroll progress value derived from the Summary scroll offset. A new dedicated profile section will replace the static `identityCard`, and `SummaryPortraitView` will be generalized so the same portrait renderer can support both expanded rounded-square and collapsed compact states.

**Tech Stack:** SwiftUI, PhotosUI, Swift Testing, source-level view structure tests

---

### Task 1: Add failing tests for the Summary scroll portrait structure

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheetTests/StatsOverviewViewTests.swift`
- Test: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheetTests/StatsOverviewViewTests.swift`

**Step 1: Write the failing test**

Add source-level expectations for:

- a dedicated profile section replacing `identityCard(character:viewModel:)`
- scroll-offset preference plumbing in `StatsOverviewView`
- a clamped collapse progress value used by the profile section

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/StatsOverviewViewTests`

Expected: FAIL because the new profile section and scroll-progress code do not exist yet.

**Step 3: Commit**

Do not commit yet. Continue to implementation once the failure is confirmed.

### Task 2: Add scroll offset plumbing to Summary

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet/StatsOverviewView.swift`

**Step 1: Add offset state and preference helper**

Introduce:

- a `@State` property to hold scroll offset
- a `PreferenceKey` for the Summary scroll view's vertical offset
- a narrow geometry reader that publishes the scroll position

**Step 2: Compute collapse progress**

Add a helper that maps scroll offset into a clamped `0...1` progress value.

**Step 3: Run targeted test**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/StatsOverviewViewTests`

Expected: still failing until the profile section replaces the old card.

### Task 3: Replace the fixed identity card with a scroll-reactive profile section

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet/StatsOverviewView.swift`

**Step 1: Introduce a dedicated profile section view**

Create private view helpers inside `StatsOverviewView.swift` for:

- expanded/collapsed portrait container layout
- metadata block layout
- camera badge overlay

**Step 2: Remove the old `identityCard` from the Summary stack**

Replace the existing `identityCard(character:viewModel:)` call in `summaryContent(for:)` with the new profile section.

**Step 3: Drive frames, offsets, and spacing from progress**

Use the collapse progress to control:

- portrait size
- portrait corner radius
- metadata vertical movement
- section spacing/top padding

**Step 4: Run targeted tests**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/StatsOverviewViewTests`

Expected: PASS once the source-level structure matches the new design.

### Task 4: Generalize portrait rendering for both expanded and collapsed states

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet/SummaryPortraitView.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet/StatsOverviewView.swift`

**Step 1: Extend `SummaryPortraitView`**

Add parameters for:

- size
- corner radius
- inner padding for the fallback rune image

Keep existing default behavior available so callers do not need unnecessary changes.

**Step 2: Wire the new parameters into the profile section**

Use the collapse progress to pass dynamic portrait size and corner radius values into `SummaryPortraitView`.

**Step 3: Run targeted tests**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/StatsOverviewViewTests`

Expected: PASS

### Task 5: Verify the full unit target and review the result

**Files:**
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet/StatsOverviewView.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet/SummaryPortraitView.swift`
- Modify: `/Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheetTests/StatsOverviewViewTests.swift`

**Step 1: Run the full unit suite**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests`

Expected: PASS

**Step 2: Review the diff**

Run: `git diff -- /Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet/StatsOverviewView.swift /Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheet/SummaryPortraitView.swift /Users/rog/Development/RQSheet/.worktrees/codex-summary-scroll-portrait/RQSheetTests/StatsOverviewViewTests.swift`

Confirm:

- no unrelated files changed
- portrait edit affordance still exists
- the old fixed identity card is gone

**Step 3: Commit**

```bash
git add RQSheet/StatsOverviewView.swift RQSheet/SummaryPortraitView.swift RQSheetTests/StatsOverviewViewTests.swift docs/plans/2026-03-08-summary-scroll-portrait-design.md docs/plans/2026-03-08-summary-scroll-portrait.md
git commit -m "Animate summary portrait on scroll"
```
