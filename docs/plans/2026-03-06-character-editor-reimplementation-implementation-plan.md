# Character Editor Reimplementation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the Character Editor into a modular, collapsible-section editor with auto-save, full passions management, portrait editing, and a flexible dice engine for stat generation.

**Architecture:** Keep `CharacterEditorView` as the route entry and compose a feature-split editor module driven by a `@MainActor @Observable` view model. Add an extensible dice domain layer (`DiceExpression`, `DiceRoller`, `StatRollProfile`) decoupled from UI. Implement section subviews and shared editor rows so behavior is testable and future race/profile expansion is additive.

**Tech Stack:** Swift 6.2, SwiftUI, SwiftData, PhotosUI, Observation, `Testing`, xcodebuild.

---

Implementation references: `@test-driven-development`, `@verification-before-completion`, `@requesting-code-review`.

### Task 1: Add failing tests for dice parsing grammar

**Files:**
- Create: `RQSheetTests/DiceExpressionParserTests.swift`
- Create: `RQSheet/Editor/DiceExpression.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import RQSheet

struct DiceExpressionParserTests {
    @Test func parsesStandardExpression() throws {
        let expression = try DiceExpression(parsing: "3d6+4")
        #expect(expression.diceCount == 3)
        #expect(expression.sides == 6)
        #expect(expression.dropRule == nil)
        #expect(expression.modifier == 4)
    }

    @Test func parsesDropLowestAndHighestCaseInsensitively() throws {
        let low = try DiceExpression(parsing: "4d6l+1")
        let high = try DiceExpression(parsing: "3d8H-1")

        #expect(low.dropRule == .lowest(1))
        #expect(high.dropRule == .highest(1))
        #expect(high.modifier == -1)
    }

    @Test func rejectsMalformedInput() {
        #expect(throws: DiceExpression.ParseError.self) {
            _ = try DiceExpression(parsing: "d6")
        }
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/DiceExpressionParserTests
```

Expected: FAIL with missing `DiceExpression`/`ParseError` symbols.

**Step 3: Write minimal implementation**

Add `RQSheet/Editor/DiceExpression.swift` implementing:

```swift
enum DropRule: Equatable {
    case lowest(Int)
    case highest(Int)
}

struct DiceExpression: Equatable {
    enum ParseError: Error {
        case invalidFormat
        case invalidDiceCount
        case invalidSides
        case invalidModifier
    }

    let diceCount: Int
    let sides: Int
    let dropRule: DropRule?
    let modifier: Int

    init(parsing source: String) throws {
        // parse NdS[H|L][+/-K]
    }

    var normalizedDescription: String {
        // e.g. "4d6L+1"
    }
}
```

Constraints:
- `diceCount >= 1`
- `sides >= 2`
- only single-drop rule (`L`/`H`) with drop count of 1 for now
- `normalizedDescription` uppercases `L`/`H`

**Step 4: Run test to verify it passes**

Run command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/Editor/DiceExpression.swift RQSheetTests/DiceExpressionParserTests.swift
git commit -m "test+dice: add dice expression parser with drop modifiers"
```

### Task 2: Add failing tests for deterministic dice rolling

**Files:**
- Create: `RQSheetTests/DiceRollerTests.swift`
- Create: `RQSheet/Editor/DiceRoller.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import RQSheet

struct DiceRollerTests {
    @Test func rollsAndDropsLowestCorrectly() throws {
        var rng = FixedSequenceRNG(values: [1, 6, 4, 3])
        let expression = try DiceExpression(parsing: "4d6L+1")

        let result = DefaultDiceRoller().roll(expression, using: &rng)

        #expect(result.rolls == [1, 6, 4, 3])
        #expect(result.dropped == [1])
        #expect(result.kept == [6, 4, 3])
        #expect(result.total == 14)
    }

    @Test func rollsAndDropsHighestCorrectly() throws {
        var rng = FixedSequenceRNG(values: [8, 2, 5])
        let expression = try DiceExpression(parsing: "3d8H-1")

        let result = DefaultDiceRoller().roll(expression, using: &rng)

        #expect(result.dropped == [8])
        #expect(result.kept == [2, 5])
        #expect(result.total == 6)
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/DiceRollerTests
```

Expected: FAIL with missing `DefaultDiceRoller`, `DiceRollResult`, `FixedSequenceRNG`.

**Step 3: Write minimal implementation**

Implement in `RQSheet/Editor/DiceRoller.swift`:

```swift
protocol DiceRoller {
    func roll<R: RandomNumberGenerator>(_ expression: DiceExpression, using rng: inout R) -> DiceRollResult
}

struct DiceRollResult: Equatable {
    let rolls: [Int]
    let kept: [Int]
    let dropped: [Int]
    let subtotal: Int
    let modifier: Int
    let total: Int
}

struct DefaultDiceRoller: DiceRoller {
    func roll<R: RandomNumberGenerator>(_ expression: DiceExpression, using rng: inout R) -> DiceRollResult {
        // generate rolls, apply drop rule, sum + modifier
    }
}

struct FixedSequenceRNG: RandomNumberGenerator {
    // deterministic helper for tests
}
```

Ensure behavior is deterministic with provided sequence and respects drop rules.

**Step 4: Run test to verify it passes**

Run command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/Editor/DiceRoller.swift RQSheetTests/DiceRollerTests.swift
git commit -m "test+dice: add deterministic dice roller"
```

### Task 3: Add failing tests for default stat roll profile

**Files:**
- Create: `RQSheetTests/StatRollProfileTests.swift`
- Create: `RQSheet/Editor/StatRollProfile.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import RQSheet

struct StatRollProfileTests {
    @Test func defaultProfileUsesExpectedExpressions() throws {
        let profile = StatRollProfile.defaultHuman

        #expect(profile.expression(for: .siz).normalizedDescription == "2d6+6")
        #expect(profile.expression(for: .int).normalizedDescription == "2d6+6")

        #expect(profile.expression(for: .str).normalizedDescription == "4d6L")
        #expect(profile.expression(for: .con).normalizedDescription == "4d6L")
        #expect(profile.expression(for: .dex).normalizedDescription == "4d6L")
        #expect(profile.expression(for: .pow).normalizedDescription == "4d6L")
        #expect(profile.expression(for: .cha).normalizedDescription == "4d6L")
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/StatRollProfileTests
```

Expected: FAIL with missing `StatRollProfile`.

**Step 3: Write minimal implementation**

Implement `StatRollProfile` in `RQSheet/Editor/StatRollProfile.swift`:

```swift
enum CharacteristicKey: CaseIterable {
    case str, con, siz, dex, int, pow, cha
}

struct StatRollProfile {
    private let expressions: [CharacteristicKey: DiceExpression]

    func expression(for key: CharacteristicKey) -> DiceExpression { ... }

    static let defaultHuman = StatRollProfile(
        expressions: [
            .siz: try! DiceExpression(parsing: "2d6+6"),
            .int: try! DiceExpression(parsing: "2d6+6"),
            .str: try! DiceExpression(parsing: "4d6L"),
            .con: try! DiceExpression(parsing: "4d6L"),
            .dex: try! DiceExpression(parsing: "4d6L"),
            .pow: try! DiceExpression(parsing: "4d6L"),
            .cha: try! DiceExpression(parsing: "4d6L"),
        ]
    )
}
```

Avoid force-try in production implementation; use internal safe construction helper.

**Step 4: Run test to verify it passes**

Run command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/Editor/StatRollProfile.swift RQSheetTests/StatRollProfileTests.swift
git commit -m "test+dice: add configurable stat roll profiles"
```

### Task 4: Add failing tests for editor view model behaviors

**Files:**
- Create: `RQSheet/Editor/CharacterEditorViewModel.swift`
- Create: `RQSheetTests/CharacterEditorViewModelTests.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import RQSheet

struct CharacterEditorViewModelTests {
    @Test @MainActor
    func sectionStateToggles() {
        let character = RQCharacter()
        let vm = CharacterEditorViewModel(character: character)

        #expect(vm.expandedSections.contains(.identity))
        vm.toggle(.identity)
        #expect(vm.expandedSections.contains(.identity) == false)
    }

    @Test @MainActor
    func applyRolledStatUsesSetCharacteristicPath() {
        let character = RQCharacter()
        let vm = CharacterEditorViewModel(character: character)

        vm.applyCharacteristic(.str, value: 18)
        #expect(character.str == 18)
    }

    @Test @MainActor
    func passionsCrudAndReorderPersistSortOrder() {
        let character = RQCharacter()
        let vm = CharacterEditorViewModel(character: character)

        vm.addPassion(description: "Loyalty", percentage: 60)
        vm.addPassion(description: "Hate", percentage: 70)
        vm.movePassions(from: IndexSet(integer: 1), to: 0)

        #expect(character.passions.count == 2)
        #expect(character.passions.sorted { $0.sortOrder < $1.sortOrder }[0].descriptionText == "Hate")
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEditorViewModelTests
```

Expected: FAIL with missing view model/section API.

**Step 3: Write minimal implementation**

Create `CharacterEditorViewModel` with:
- `@MainActor @Observable`
- `expandedSections: Set<EditorSection>`
- `toggle(_:)`
- `applyCharacteristic(_:value:)` using `character.setCharacteristic`
- `addPassion`, `updatePassion`, `deletePassion`, `movePassions`
- profile + dice roller references
- placeholder portrait actions

**Step 4: Run test to verify it passes**

Run command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/Editor/CharacterEditorViewModel.swift RQSheetTests/CharacterEditorViewModelTests.swift
git commit -m "test+vm: add character editor view model core behaviors"
```

### Task 5: Rebuild CharacterEditorView into modular collapsible sections

**Files:**
- Modify: `RQSheet/CharacterEditorView.swift`
- Create: `RQSheet/Editor/EditorSectionContainer.swift`
- Create: `RQSheet/Editor/EditorFieldRows.swift`
- Create: `RQSheet/Editor/EditorIdentitySectionView.swift`
- Create: `RQSheet/Editor/EditorCharacteristicsSectionView.swift`
- Create: `RQSheet/Editor/EditorCombatAndDerivedSectionView.swift`
- Create: `RQSheet/Editor/EditorSocialSectionView.swift`
- Create: `RQSheet/Editor/EditorEconomySectionView.swift`
- Create: `RQSheet/Editor/EditorPassionsSectionView.swift`

**Step 1: Write the failing test**

Add a lightweight view-model test in `CharacterEditorViewModelTests.swift`:

```swift
@Test @MainActor
func allCoreSectionsExist() {
    let vm = CharacterEditorViewModel(character: RQCharacter())
    #expect(vm.availableSections.contains(.identity))
    #expect(vm.availableSections.contains(.characteristics))
    #expect(vm.availableSections.contains(.social))
    #expect(vm.availableSections.contains(.passions))
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEditorViewModelTests/allCoreSectionsExist
```

Expected: FAIL for missing section APIs.

**Step 3: Write minimal implementation**

- Introduce section enum and expose `availableSections`.
- Replace monolithic editor with section composition.
- Keep auto-save via bindings.
- Ensure Identity includes portrait controls.
- Ensure Passions section supports add/edit/delete/reorder UI.

**Step 4: Run test to verify it passes**

Run command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/CharacterEditorView.swift RQSheet/Editor/*.swift RQSheetTests/CharacterEditorViewModelTests.swift
git commit -m "feat(editor): reimplement character editor with modular collapsible sections"
```

### Task 6: Add dice UI flow for characteristic rows

**Files:**
- Modify: `RQSheet/Editor/EditorCharacteristicsSectionView.swift`
- Create: `RQSheet/Editor/StatDiceRollerView.swift`

**Step 1: Write the failing test**

Add in `CharacterEditorViewModelTests.swift`:

```swift
@Test @MainActor
func parseAndRollValidationStateBehavesForInvalidFormula() {
    let vm = CharacterEditorViewModel(character: RQCharacter())
    vm.setCustomExpression("not-a-formula", for: .str)

    #expect(vm.rollValidationError(for: .str) != nil)
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEditorViewModelTests/parseAndRollValidationStateBehavesForInvalidFormula
```

Expected: FAIL for missing formula validation APIs.

**Step 3: Write minimal implementation**

- Add per-stat custom expression state.
- Add parse/validation helpers.
- Add `StatDiceRollerView` UI:
  - formula field
  - roll button
  - apply button
  - inline error text
- Connect to characteristics rows with a dice action button.

**Step 4: Run test to verify it passes**

Run command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/Editor/EditorCharacteristicsSectionView.swift RQSheet/Editor/StatDiceRollerView.swift RQSheet/Editor/CharacterEditorViewModel.swift RQSheetTests/CharacterEditorViewModelTests.swift
git commit -m "feat(editor): add dice rolling workflow for characteristics"
```

### Task 7: Verify passions full management interactions

**Files:**
- Modify: `RQSheet/Editor/EditorPassionsSectionView.swift`
- Modify: `RQSheetTests/CharacterEditorViewModelTests.swift`

**Step 1: Write failing/edge tests**

Add tests:

```swift
@Test @MainActor
func deletingPassionReindexesSortOrder() {
    let vm = CharacterEditorViewModel(character: RQCharacter())
    vm.addPassion(description: "A", percentage: 50)
    vm.addPassion(description: "B", percentage: 60)
    vm.deletePassions(at: IndexSet(integer: 0))

    let ordered = vm.character.passions.sorted { $0.sortOrder < $1.sortOrder }
    #expect(ordered.count == 1)
    #expect(ordered[0].sortOrder == 0)
}
```

**Step 2: Run test to verify it fails**

Run focused test command on `CharacterEditorViewModelTests`.

Expected: FAIL if reindexing is incomplete.

**Step 3: Write minimal implementation**

- Ensure delete and reorder both normalize `sortOrder` sequence.
- Ensure section view uses move/delete handlers correctly.

**Step 4: Run test to verify it passes**

Run focused test command.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/Editor/EditorPassionsSectionView.swift RQSheet/Editor/CharacterEditorViewModel.swift RQSheetTests/CharacterEditorViewModelTests.swift
git commit -m "fix(editor): harden passions reorder and delete ordering"
```

### Task 8: Full verification before completion

**Files:**
- Modify: none (verification and fixes only)

**Step 1: Run targeted new suites**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/DiceExpressionParserTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/DiceRollerTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/StatRollProfileTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEditorViewModelTests
```

Expected: PASS for all targeted suites.

**Step 2: Run existing regression suites impacted by editor/summary**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SummaryViewModelTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterHonorAndPassionTests
```

Expected: PASS.

**Step 3: Run full suite**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17'
```

Expected: `** TEST SUCCEEDED **`.

**Step 4: Run SwiftLint if installed**

Run:
```bash
swiftlint
```

Expected: no warnings/errors or `command not found` documented explicitly.

**Step 5: Final commit**

```bash
git add -A
git commit -m "feat(editor): reimplement character editor with modular sections and dice rolling"
```

