# Equipment Page Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the Equipment tab placeholder with a persisted, searchable equipment workflow and add equipped/total ENC visibility to Summary Derived Stats.

**Architecture:** Add a new SwiftData `CharacterEquipmentItem` model related to `RQCharacter`, then build an equipment-focused UI flow (`EquipmentView` list + pushed detail editor) on top of it. Keep UI logic in a dedicated `@MainActor @Observable` view model so search ranking and ENC totals are testable. Integrate ENC totals into `SummaryViewModel` and `StatsOverviewView` without changing existing summary card structure.

**Tech Stack:** Swift 6.2, SwiftUI, SwiftData, Observation, Testing, xcodebuild.

---

Implementation references: `@test-driven-development`, `@verification-before-completion`, `@requesting-code-review`.

### Task 1: Add failing model tests for equipment persistence and relationship

**Files:**
- Create: `RQSheetTests/CharacterEquipmentTests.swift`
- Modify: `RQSheetTests/SummaryPersistenceIntegrationTests.swift`

**Step 1: Write the failing tests**

```swift
import SwiftData
import Testing
@testable import RQSheet

struct CharacterEquipmentTests {
    @Test
    func addEquipmentItemAssignsSortOrderAndDefaults() {
        let character = RQCharacter(name: "Arkat")

        character.addEquipmentItem(name: "Backpack", encumbrance: 2, notes: "Worn", isEquipped: true)
        character.addEquipmentItem(name: "Bedroll", encumbrance: 1, notes: "", isEquipped: false)

        #expect(character.equipmentItems.count == 2)
        let ordered = character.equipmentItems.sorted { $0.sortOrder < $1.sortOrder }
        #expect(ordered[0].sortOrder == 0)
        #expect(ordered[1].sortOrder == 1)
        #expect(ordered[0].character === character)
    }

    @Test
    func equipmentEncumbranceIsClampedToNonNegative() {
        let item = CharacterEquipmentItem(name: "Torch", encumbrance: -2)
        #expect(item.encumbrance == 0)
        item.encumbrance = -9
        #expect(item.encumbrance == 0)
    }
}
```

Also extend `canInsertCharacterWithHonorAndPassionsIntoSwiftDataContainer()` to include an inserted equipment item and assert it round-trips.

**Step 2: Run tests to verify they fail**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEquipmentTests -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: FAIL due missing `CharacterEquipmentItem` and missing `RQCharacter.equipmentItems`/`addEquipmentItem`.

**Step 3: Write minimal implementation scaffolding**

No implementation in this task (tests-only commit).

**Step 4: Re-run test to confirm still failing for expected reasons**

Run command from Step 2.
Expected: FAIL with model symbols not found.

**Step 5: Commit**

```bash
git add RQSheetTests/CharacterEquipmentTests.swift RQSheetTests/SummaryPersistenceIntegrationTests.swift
git commit -m "test(equipment): add failing persistence and model behavior tests"
```

### Task 2: Implement equipment model and character integration

**Files:**
- Create: `RQSheet/CharacterEquipmentItem.swift`
- Modify: `RQSheet/Character.swift`
- Modify: `RQSheet/RQSheetApp.swift`
- Modify: `RQSheet/ContentView.swift`
- Modify: `RQSheetTests/SummaryPersistenceIntegrationTests.swift`

**Step 1: Implement SwiftData model**

Create `CharacterEquipmentItem`:

```swift
import Foundation
import SwiftData

@Model
final class CharacterEquipmentItem {
    var name: String
    var encumbrance: Int { didSet { if encumbrance < 0 { encumbrance = 0 } } }
    var notes: String
    var isEquipped: Bool
    var sortOrder: Int
    var character: RQCharacter?

    init(
        name: String = "",
        encumbrance: Int = 0,
        notes: String = "",
        isEquipped: Bool = false,
        sortOrder: Int = 0,
        character: RQCharacter? = nil
    ) {
        self.name = name
        self.encumbrance = max(0, encumbrance)
        self.notes = notes
        self.isEquipped = isEquipped
        self.sortOrder = sortOrder
        self.character = character
    }
}
```

**Step 2: Add relationship and helper to `RQCharacter`**

Add:

```swift
var equipmentItems: [CharacterEquipmentItem] = []

func addEquipmentItem(name: String = "", encumbrance: Int = 0, notes: String = "", isEquipped: Bool = false) {
    let nextSortOrder = (equipmentItems.map(\.sortOrder).max() ?? -1) + 1
    let item = CharacterEquipmentItem(
        name: name,
        encumbrance: max(0, encumbrance),
        notes: notes,
        isEquipped: isEquipped,
        sortOrder: nextSortOrder,
        character: self
    )
    equipmentItems.append(item)
}
```

Update initializer to accept `equipmentItems` and back-link `item.character = self`.

**Step 3: Register model in all schemas**

Add `CharacterEquipmentItem.self` to:
- `RQSheetApp` schema
- `ContentView` preview container
- in-memory test schema in `SummaryPersistenceIntegrationTests`

**Step 4: Run tests to verify pass**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEquipmentTests -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/CharacterEquipmentItem.swift RQSheet/Character.swift RQSheet/RQSheetApp.swift RQSheet/ContentView.swift RQSheetTests/CharacterEquipmentTests.swift RQSheetTests/SummaryPersistenceIntegrationTests.swift
git commit -m "feat(equipment): add persisted equipment model and character relationship"
```

### Task 3: Add failing tests for equipment search ranking and ENC totals

**Files:**
- Create: `RQSheet/Equipment/EquipmentViewModel.swift`
- Create: `RQSheetTests/EquipmentViewModelTests.swift`

**Step 1: Write failing tests**

```swift
import Testing
@testable import RQSheet

struct EquipmentViewModelTests {
    @Test
    @MainActor
    func searchPrioritizesNameMatchesOverNotesMatches() {
        let character = RQCharacter(name: "Arkat")
        character.addEquipmentItem(name: "Torch", encumbrance: 1, notes: "Light source", isEquipped: true)
        character.addEquipmentItem(name: "Rope", encumbrance: 1, notes: "Used with torch", isEquipped: false)

        let vm = EquipmentViewModel(character: character)
        vm.searchText = "torch"

        #expect(vm.filteredItems.count == 2)
        #expect(vm.filteredItems[0].name == "Torch")
    }

    @Test
    @MainActor
    func totalsComputeEquippedAndOverallEncumbrance() {
        let character = RQCharacter(name: "Arkat")
        character.addEquipmentItem(name: "Backpack", encumbrance: 2, notes: "", isEquipped: true)
        character.addEquipmentItem(name: "Bedroll", encumbrance: 1, notes: "", isEquipped: false)

        let vm = EquipmentViewModel(character: character)

        #expect(vm.totalEncumbrance == 3)
        #expect(vm.equippedEncumbrance == 2)
        #expect(vm.encumbranceSummaryText == "2 / 3")
    }
}
```

**Step 2: Run tests to verify they fail**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/EquipmentViewModelTests
```

Expected: FAIL for missing `EquipmentViewModel`.

**Step 3: Implement minimal `EquipmentViewModel`**

Create `@MainActor @Observable` view model with:
- `character`
- `searchText`
- `filteredItems`
- `totalEncumbrance`
- `equippedEncumbrance`
- `encumbranceSummaryText`
- item sorting and search ranking helper (`name` matches before `notes` matches).

**Step 4: Run tests to verify pass**

Run command from Step 2.
Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/Equipment/EquipmentViewModel.swift RQSheetTests/EquipmentViewModelTests.swift
git commit -m "feat(equipment): add equipment view model with ranked search and totals"
```

### Task 4: Rebuild Equipment tab with list, search, push editor, and scroll behavior

**Files:**
- Modify: `RQSheet/EquipmentView.swift`
- Create: `RQSheet/Equipment/EquipmentRowView.swift`
- Create: `RQSheet/Equipment/EquipmentItemEditorView.swift`

**Step 1: Write a targeted UI behavior smoke test (view-model level)**

Add test in `EquipmentViewModelTests.swift`:

```swift
@Test
@MainActor
func deletingAndReorderingNormalizesSortOrder() {
    let character = RQCharacter(name: "Arkat")
    character.addEquipmentItem(name: "A", encumbrance: 1)
    character.addEquipmentItem(name: "B", encumbrance: 1)

    let vm = EquipmentViewModel(character: character)
    vm.moveItems(from: IndexSet(integer: 1), to: 0)

    let ordered = vm.sortedItems
    #expect(ordered[0].name == "B")
    #expect(ordered[0].sortOrder == 0)
}
```

**Step 2: Run to verify fail**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/EquipmentViewModelTests/deletingAndReorderingNormalizesSortOrder
```

Expected: FAIL for missing move/delete APIs.

**Step 3: Implement Equipment UI + remaining view-model actions**

Implement:
- `EquipmentView` inside `NavigationStack` with overlay search bar and scroll-under behavior.
- top ENC summary strip (`Equipped ENC`, `Total ENC`).
- list rows (`name`, `ENC`, `equipped` + optional notes).
- row `NavigationLink` to `EquipmentItemEditorView`.
- add button creating item + navigate to editor.
- delete and reorder wired through view model.

**Step 4: Run targeted tests**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/EquipmentViewModelTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/EquipmentView.swift RQSheet/Equipment/EquipmentRowView.swift RQSheet/Equipment/EquipmentItemEditorView.swift RQSheet/Equipment/EquipmentViewModel.swift RQSheetTests/EquipmentViewModelTests.swift
git commit -m "feat(equipment): implement equipment tab with search and row editor"
```

### Task 5: Add Summary ENC chip integration

**Files:**
- Modify: `RQSheet/SummaryViewModel.swift`
- Modify: `RQSheet/StatsOverviewView.swift`
- Modify: `RQSheetTests/SummaryViewModelTests.swift`

**Step 1: Write failing summary tests**

Add in `SummaryViewModelTests.swift`:

```swift
@Test
@MainActor
func encumbranceSummaryTextReflectsEquippedAndTotal() {
    let character = RQCharacter(name: "Arkat")
    character.addEquipmentItem(name: "Pack", encumbrance: 2, isEquipped: true)
    character.addEquipmentItem(name: "Bedroll", encumbrance: 1, isEquipped: false)

    let viewModel = SummaryViewModel(character: character)

    #expect(viewModel.equipmentEncumbranceText == "2 / 3")
}
```

**Step 2: Run to verify fail**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SummaryViewModelTests/encumbranceSummaryTextReflectsEquippedAndTotal
```

Expected: FAIL for missing summary property.

**Step 3: Implement Summary integration**

- Add `equipmentEncumbranceText` to `SummaryViewModel`.
- Add derived chip in `StatsOverviewView` `derivedStatsCard`:
  - label `ENC`
  - value `equipped / total`.

**Step 4: Run targeted tests**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SummaryViewModelTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/SummaryViewModel.swift RQSheet/StatsOverviewView.swift RQSheetTests/SummaryViewModelTests.swift
git commit -m "feat(summary): add equipment encumbrance chip"
```

### Task 6: End-to-end verification and cleanup

**Files:**
- Modify: none (unless fixes required)

**Step 1: Run equipment-focused suites**

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEquipmentTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/EquipmentViewModelTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SummaryViewModelTests
```

Expected: all PASS.

**Step 2: Run impacted regression suites**

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEditorViewModelTests
```

Expected: PASS.

**Step 3: Run full test suite**

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17'
```

Expected: `** TEST SUCCEEDED **`.

**Step 4: Run SwiftLint if installed**

```bash
swiftlint
```

Expected: no warnings/errors, or `command not found` documented.

**Step 5: Final commit**

```bash
git add -A
git commit -m "feat(equipment): implement equipment tab with persisted items and summary encumbrance"
```
