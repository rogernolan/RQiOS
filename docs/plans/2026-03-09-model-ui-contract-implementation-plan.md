# Model/UI Contract Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update the character and weapon model contract so income and strike rank are text-backed, move and several weapon fields can be missing, and the UI renders the new fallback states correctly.

**Architecture:** Change the persisted types directly on `RQCharacter` and `WeaponSkill`, then update the existing summary, combat, skill, and editor layers to render fallback display state without writing placeholder values back into storage. Keep the change narrow by reusing the current `SummaryViewModel`, `SkillsView`, `CombatView`, and editor sections rather than introducing new wrapper models.

**Tech Stack:** SwiftUI, SwiftData, Swift Testing, `xcodebuild`.

---

### Task 1: Add failing tests for the new model contract

**Files:**
- Create: `RQSheetTests/WeaponSkillTests.swift`
- Modify: `RQSheetTests/SummaryViewModelTests.swift`
- Modify: `RQSheetTests/SkillsViewTests.swift`

**Step 1: Write the failing test**

Add tests covering:
- `SummaryViewModel` renders missing move as `"8"`
- `SummaryViewModel.skillBonuses` now includes seven groups
- `WeaponSkill` can store string `strikeRank`
- `WeaponSkill` can store `nil` for `hpMax`, `hpCurrent`, `enc`, and `type`

Include tests like:

```swift
@Test
@MainActor
func missingMoveFallsBackToEight() {
    let character = RQCharacter()
    character.move = nil

    let viewModel = SummaryViewModel(character: character)

    #expect(viewModel.moveText == "8")
}
```

```swift
@Test
func weaponSkillAllowsMissingCombatFields() {
    let weapon = WeaponSkill(
        name: "Sling",
        damage: "1d6",
        hpMax: nil,
        hpCurrent: nil,
        enc: nil,
        strikeRank: "missile",
        type: nil
    )

    #expect(weapon.hpMax == nil)
    #expect(weapon.strikeRank == "missile")
    #expect(weapon.type == nil)
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/SummaryViewModelTests -only-testing:RQSheetTests/SkillsViewTests -only-testing:RQSheetTests/WeaponSkillTests
```

Expected: FAIL because the model types and skill-group count still reflect the old contract.

**Step 3: Write minimal implementation**

Do not implement yet. This task ends once the failing expectations clearly point at the missing contract changes.

**Step 4: Run test to verify it passes**

Do not run a passing check in this task.

**Step 5: Commit**

Do not commit in the red phase.

### Task 2: Update the model types and summary view model

**Files:**
- Modify: `RQSheet/Character.swift`
- Modify: `RQSheet/WeaponSkill.swift`
- Modify: `RQSheet/SummaryViewModel.swift`
- Modify: `RQSheetTests/SummaryViewModelTests.swift`
- Modify: `RQSheetTests/WeaponSkillTests.swift`

**Step 1: Write the failing test**

Use the tests from Task 1 as the red state. If coverage is still missing after the first compile failure, add only the smallest extra assertion needed.

**Step 2: Run test to verify it fails**

Run the Task 1 command again and confirm the failure is caused by the old type signatures or old display behavior.

**Step 3: Write minimal implementation**

Implement:
- `RQCharacter.income: String`
- `RQCharacter.move: Int?`
- `WeaponSkill.strikeRank: String`
- `WeaponSkill.hpMax`, `hpCurrent`, `enc`, `type` as optionals
- minimal initializer and clamping updates so optional fields stay optional
- `SummaryViewModel.moveText` fallback to `8`

Keep this task limited to model and view-model logic. Do not touch SwiftUI rendering yet.

**Step 4: Run test to verify it passes**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/SummaryViewModelTests -only-testing:RQSheetTests/WeaponSkillTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract add RQSheet/Character.swift RQSheet/WeaponSkill.swift RQSheet/SummaryViewModel.swift RQSheetTests/SummaryViewModelTests.swift RQSheetTests/WeaponSkillTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract commit -m "refactor(model): update character and weapon field types"
```

### Task 3: Add the `magic` skill group across model and list rendering

**Files:**
- Modify: `RQSheet/SkillGroup.swift`
- Modify: `RQSheet/Character.swift`
- Modify: `RQSheet/SummaryViewModel.swift`
- Modify: `RQSheet/SkillsView.swift`
- Modify: `RQSheetTests/SkillsViewTests.swift`
- Modify: `RQSheetTests/SummaryViewModelTests.swift`

**Step 1: Write the failing test**

Extend tests to assert:
- `SkillGroup.allCases` includes `.magic`
- skill-bonus lists now expose seven entries
- `SkillsView` contains the new magic group title

Use source assertions only where this codebase already prefers them.

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/SummaryViewModelTests -only-testing:RQSheetTests/SkillsViewTests
```

Expected: FAIL because `magic` is not yet part of the enum or title switches.

**Step 3: Write minimal implementation**

Implement:
- `.magic` in `SkillGroup`
- title handling for `.magic` in `SummaryViewModel` and `SkillsView`
- bonus handling for `.magic` in `RQCharacter.bonus(for:)`

Do not add any unrelated magic-skill behavior in this task.

**Step 4: Run test to verify it passes**

Run the same command.

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract add RQSheet/SkillGroup.swift RQSheet/Character.swift RQSheet/SummaryViewModel.swift RQSheet/SkillsView.swift RQSheetTests/SkillsViewTests.swift RQSheetTests/SummaryViewModelTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract commit -m "feat(skills): add magic skill group"
```

### Task 4: Update summary and editor UI for the new character contract

**Files:**
- Modify: `RQSheet/StatsOverviewView.swift`
- Modify: `RQSheet/Editor/EditorCombatAndDerivedSectionView.swift`
- Modify: `RQSheet/Editor/EditorEconomySectionView.swift`
- Modify: `RQSheetTests/StatsOverviewViewTests.swift`

**Step 1: Write the failing test**

Add source assertions for:
- move rendering path that distinguishes fallback styling from regular styling
- economy/editor bindings that now use `String` for income and optional handling for move
- no appended `L` in income rendering, if an income renderer exists in these files

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/StatsOverviewViewTests
```

Expected: FAIL because the summary/editor UI still assumes a non-optional numeric move and old income contract.

**Step 3: Write minimal implementation**

Implement:
- grey/secondary display for fallback move `8`
- optional move editing path in the combat-derived editor section
- string-backed income binding in the economy editor section
- remove any trailing `L` rendering

Keep fallback display logic in the view/view-model layer, not in stored values.

**Step 4: Run test to verify it passes**

Run the same command.

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract add RQSheet/StatsOverviewView.swift RQSheet/Editor/EditorCombatAndDerivedSectionView.swift RQSheet/Editor/EditorEconomySectionView.swift RQSheetTests/StatsOverviewViewTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract commit -m "feat(summary): render fallback move and string income"
```

### Task 5: Update combat rendering and add-weapon input behavior

**Files:**
- Modify: `RQSheet/CombatView.swift`
- Create: `RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing test**

Create source tests that assert:
- weapon rows render string `strikeRank`
- missing `hpMax`, `hpCurrent`, `enc`, and `type` render as `-`
- add-weapon save flow passes raw `strikeRank` text
- blank optional fields are converted to `nil`

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/CombatViewTests
```

Expected: FAIL because combat rows and add-weapon save logic still coerce these fields into non-optional numeric/enum values.

**Step 3: Write minimal implementation**

Implement:
- row helpers that format missing optional values as `-`
- HP column rendering as `-` unless both values are present
- raw string strike-rank display
- add-weapon parsing that treats blank optional inputs as `nil`

If `enc` or `type` remain unrendered in the visible row, limit the implementation to stored/edit behavior and only test what the UI actually shows.

**Step 4: Run test to verify it passes**

Run the same command.

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract add RQSheet/CombatView.swift RQSheetTests/CombatViewTests.swift
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract commit -m "feat(combat): support optional weapon fields"
```

### Task 6: Run focused regression coverage and clean up

**Files:**
- Modify: any files changed in prior tasks if a failing regression requires a small follow-up fix

**Step 1: Write the failing test**

Do not add new tests unless a regression is uncovered by the verification run.

**Step 2: Run test to verify it fails**

Run the focused regression suite:

```bash
xcodebuild -project /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:RQSheetTests/SummaryViewModelTests -only-testing:RQSheetTests/WeaponSkillTests -only-testing:RQSheetTests/SkillsViewTests -only-testing:RQSheetTests/StatsOverviewViewTests -only-testing:RQSheetTests/CombatViewTests
```

Expected: PASS. If any test fails, add the smallest missing test and fix before proceeding.

**Step 3: Write minimal implementation**

Apply only the smallest regression fix needed to restore green.

**Step 4: Run test to verify it passes**

Re-run the same focused regression suite and confirm it is green.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet/.worktrees/codex-model-ui-contract status --short
```

Commit only if Task 6 required an actual code change.
