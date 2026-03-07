# Equipment Tab Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a first-class Equipment tab with persisted items, ranked search, push-based editing, destructive delete confirmation, and ENC totals shown in both Equipment and Summary.

**Architecture:** Add a dedicated SwiftData model for equipment items and keep shared ENC business rules on `RQCharacter`. Use a small `EquipmentViewModel` for ranked filtering and header state, then compose `EquipmentView` and `EquipmentEditorView` around direct SwiftData bindings and existing app chrome patterns.

**Tech Stack:** Swift 6.2, SwiftUI, SwiftData, Observation, `Testing`, xcodebuild.

---

Implementation references: `@test-driven-development`, `@verification-before-completion`, `@requesting-code-review`.

### Task 1: Add the equipment model and character ENC rules

**Files:**
- Create: `RQSheet/CharacterEquipmentItem.swift`
- Modify: `RQSheet/Character.swift`
- Modify: `RQSheet/RQSheetApp.swift`
- Modify: `RQSheet/ContentView.swift`
- Test: `RQSheetTests/CharacterEquipmentTests.swift`

**Step 1: Write the failing test**

Create `RQSheetTests/CharacterEquipmentTests.swift` with tests for:

```swift
import Testing
@testable import RQSheet

struct CharacterEquipmentTests {
    @Test
    func addEquipmentItemAssignsIncreasingSortOrder() {
        let character = RQCharacter()

        let rope = character.addEquipmentItem(name: "Rope", encumbrance: 1, notes: "", isCurrentlyEquipped: false)
        let shield = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)

        #expect(rope.sortOrder == 0)
        #expect(shield.sortOrder == 1)
        #expect(character.equipmentItems.map(\.name) == ["Rope", "Shield"])
    }

    @Test
    func encumbranceRulesClampAndSumCorrectly() {
        let character = RQCharacter()
        character.str = 11
        character.con = 15

        _ = character.addEquipmentItem(name: "Heavy Cloak", encumbrance: -3, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Waterskin", encumbrance: 2, notes: "", isCurrentlyEquipped: false)
        _ = character.addEquipmentItem(name: "Spear", encumbrance: 3, notes: "", isCurrentlyEquipped: true)

        #expect(character.equipmentItems.map(\.encumbrance) == [0, 2, 3])
        #expect(character.currentEncumbrance == 3)
        #expect(character.maxEncumbrance == 11)
    }
}
```

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEquipmentTests
```

Expected: FAIL with missing `CharacterEquipmentItem`, `equipmentItems`, `addEquipmentItem`, `currentEncumbrance`, and `maxEncumbrance`.

**Step 3: Write minimal implementation**

Create `RQSheet/CharacterEquipmentItem.swift`:

```swift
import Foundation
import SwiftData

@Model
final class CharacterEquipmentItem {
    var name: String
    var encumbrance: Int {
        didSet {
            if encumbrance < 0 {
                encumbrance = 0
            }
        }
    }
    var notes: String
    var isCurrentlyEquipped: Bool
    var sortOrder: Int
    var character: RQCharacter?

    init(
        name: String = "",
        encumbrance: Int = 0,
        notes: String = "",
        isCurrentlyEquipped: Bool = false,
        sortOrder: Int = 0,
        character: RQCharacter? = nil
    ) {
        self.name = name
        self.encumbrance = max(0, encumbrance)
        self.notes = notes
        self.isCurrentlyEquipped = isCurrentlyEquipped
        self.sortOrder = sortOrder
        self.character = character
    }
}
```

Modify `RQSheet/Character.swift` to add:

```swift
var equipmentItems: [CharacterEquipmentItem] = []

var currentEncumbrance: Int {
    equipmentItems
        .filter(\.isCurrentlyEquipped)
        .reduce(0) { $0 + $1.encumbrance }
}

var maxEncumbrance: Int {
    min(str, (str + con) / 2)
}

@discardableResult
func addEquipmentItem(
    name: String = "",
    encumbrance: Int = 0,
    notes: String = "",
    isCurrentlyEquipped: Bool = false
) -> CharacterEquipmentItem {
    let nextSortOrder = (equipmentItems.map(\.sortOrder).max() ?? -1) + 1
    let item = CharacterEquipmentItem(
        name: name,
        encumbrance: encumbrance,
        notes: notes,
        isCurrentlyEquipped: isCurrentlyEquipped,
        sortOrder: nextSortOrder,
        character: self
    )
    equipmentItems.append(item)
    return item
}
```

Also:

- add `equipmentItems` to the initializer and set each item’s `character`
- register `CharacterEquipmentItem.self` in the explicit schema arrays in `RQSheet/RQSheetApp.swift` and `RQSheet/ContentView.swift`

**Step 4: Run test to verify it passes**

Run the command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/CharacterEquipmentItem.swift RQSheet/Character.swift RQSheet/RQSheetApp.swift RQSheet/ContentView.swift RQSheetTests/CharacterEquipmentTests.swift
git commit -m "feat: add character equipment model and encumbrance rules"
```

### Task 2: Add ranked search logic for equipment rows

**Files:**
- Create: `RQSheet/EquipmentViewModel.swift`
- Test: `RQSheetTests/EquipmentViewModelTests.swift`

**Step 1: Write the failing test**

Create `RQSheetTests/EquipmentViewModelTests.swift`:

```swift
import Testing
@testable import RQSheet

struct EquipmentViewModelTests {
    @Test
    @MainActor
    func searchRanksNameMatchesAheadOfNotesMatchesAndPreservesInsertionOrder() {
        let character = RQCharacter()
        _ = character.addEquipmentItem(name: "Fireblade", encumbrance: 2, notes: "Ceremonial sword", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Bedroll", encumbrance: 1, notes: "Smells like smoke and fire", isCurrentlyEquipped: false)
        _ = character.addEquipmentItem(name: "Firestarter", encumbrance: 0, notes: "Tinder kit", isCurrentlyEquipped: false)

        let viewModel = EquipmentViewModel(character: character)
        viewModel.searchText = "fire"

        #expect(viewModel.visibleItems.map(\.name) == ["Fireblade", "Firestarter", "Bedroll"])
    }

    @Test
    @MainActor
    func emptySearchReturnsInsertionOrder() {
        let character = RQCharacter()
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Rope", encumbrance: 1, notes: "", isCurrentlyEquipped: false)

        let viewModel = EquipmentViewModel(character: character)

        #expect(viewModel.visibleItems.map(\.name) == ["Shield", "Rope"])
        #expect(viewModel.headerEncumbranceText == "\(character.maxEncumbrance) / \(character.currentEncumbrance)")
    }
}
```

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/EquipmentViewModelTests
```

Expected: FAIL with missing `EquipmentViewModel`.

**Step 3: Write minimal implementation**

Create `RQSheet/EquipmentViewModel.swift`:

```swift
import Foundation
import Observation

@MainActor
@Observable
final class EquipmentViewModel {
    let character: RQCharacter
    var searchText = ""
    var pendingDeleteItem: CharacterEquipmentItem?

    init(character: RQCharacter) {
        self.character = character
    }

    var visibleItems: [CharacterEquipmentItem] {
        let ordered = character.equipmentItems.sorted { lhs, rhs in
            lhs.sortOrder < rhs.sortOrder
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.isEmpty == false else { return ordered }

        let lowered = query.localizedLowercase
        let nameMatches = ordered.filter { $0.name.localizedLowercase.contains(lowered) }
        let noteMatches = ordered.filter {
            $0.name.localizedLowercase.contains(lowered) == false &&
            $0.notes.localizedLowercase.contains(lowered)
        }
        return nameMatches + noteMatches
    }

    var headerEncumbranceText: String {
        "\(character.maxEncumbrance) / \(character.currentEncumbrance)"
    }
}
```

**Step 4: Run test to verify it passes**

Run the command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/EquipmentViewModel.swift RQSheetTests/EquipmentViewModelTests.swift
git commit -m "feat: add equipment search ranking view model"
```

### Task 3: Add Summary and persistence coverage for equipment ENC

**Files:**
- Modify: `RQSheet/SummaryViewModel.swift`
- Test: `RQSheetTests/SummaryViewModelTests.swift`
- Test: `RQSheetTests/SummaryPersistenceIntegrationTests.swift`

**Step 1: Write the failing test**

Extend `RQSheetTests/SummaryViewModelTests.swift` with:

```swift
    @Test
    @MainActor
    func encumbranceDisplayUsesCharacterTotals() {
        let character = RQCharacter()
        character.str = 12
        character.con = 16
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
        _ = character.addEquipmentItem(name: "Torch", encumbrance: 1, notes: "", isCurrentlyEquipped: false)

        let viewModel = SummaryViewModel(character: character)

        #expect(viewModel.encumbranceText == "12/2")
    }
```

Extend `RQSheetTests/SummaryPersistenceIntegrationTests.swift` with:

```swift
    @Test
    @MainActor
    func canInsertCharacterWithEquipmentIntoSwiftDataContainer() throws {
        let schema = Schema([
            RQCharacter.self,
            RuneAffinity.self,
            SkillDefinition.self,
            CharacterSkill.self,
            WeaponSkill.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
            CharacterEquipmentItem.self,
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let character = RQCharacter(name: "Arkat")
        _ = character.addEquipmentItem(name: "Shield", encumbrance: 2, notes: "Bronze", isCurrentlyEquipped: true)

        context.insert(character)
        try context.save()

        let results = try context.fetch(FetchDescriptor<RQCharacter>())
        #expect(results.count == 1)
        #expect(results[0].equipmentItems.count == 1)
        #expect(results[0].currentEncumbrance == 2)
    }
```

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SummaryViewModelTests -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: FAIL with missing `encumbranceText` or schema omissions.

**Step 3: Write minimal implementation**

Modify `RQSheet/SummaryViewModel.swift` to add:

```swift
var encumbranceText: String {
    "\(character.maxEncumbrance)/\(character.currentEncumbrance)"
}
```

Keep the business rule on `RQCharacter`; `SummaryViewModel` should only format it.

**Step 4: Run test to verify it passes**

Run the command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/SummaryViewModel.swift RQSheetTests/SummaryViewModelTests.swift RQSheetTests/SummaryPersistenceIntegrationTests.swift
git commit -m "test(summary): cover encumbrance display and persistence"
```

### Task 4: Build the equipment editor screen

**Files:**
- Create: `RQSheet/EquipmentEditorView.swift`

**Step 1: Write the minimal editor implementation**

Create `RQSheet/EquipmentEditorView.swift`:

```swift
import SwiftUI

struct EquipmentEditorView: View {
    @Bindable var item: CharacterEquipmentItem

    var body: some View {
        Form {
            TextField("Name", text: $item.name)

            TextField(
                "ENC",
                value: Binding(
                    get: { item.encumbrance },
                    set: { item.encumbrance = max(0, $0) }
                ),
                format: .number
            )
            .keyboardType(.numberPad)

            TextField("Description / Notes", text: $item.notes, axis: .vertical)
                .lineLimit(4, reservesSpace: true)
        }
        .navigationTitle(item.name.isEmpty ? "New Item" : item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

Use direct bindings so dismissing the pushed view implicitly preserves edits.

**Step 2: Run a build to verify the editor compiles**

Run:

```bash
xcodebuild -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: BUILD SUCCEEDED.

**Step 3: Commit**

```bash
git add RQSheet/EquipmentEditorView.swift
git commit -m "feat: add equipment item editor view"
```

### Task 5: Replace the placeholder Equipment tab with the full list flow

**Files:**
- Modify: `RQSheet/EquipmentView.swift`
- Modify: `RQSheet/EquipmentViewModel.swift`
- Modify: `RQSheet/EquipmentEditorView.swift`

**Step 1: Replace the placeholder view**

Implement `RQSheet/EquipmentView.swift` with:

- `@Query private var characters: [RQCharacter]`
- `NavigationStack`
- top overlay containing:
  - left-aligned `Equipment`
  - right-aligned bordered compact card with `viewModel.headerEncumbranceText`
  - search bar styled to match `SkillsView`
- scrollable list content extending behind the overlay and tab bar
- row cards built from the ordered `viewModel.visibleItems`
- checkbox button toggling `item.isCurrentlyEquipped`
- `NavigationLink` push to `EquipmentEditorView(item: item)` for row taps
- trailing swipe action that sets `pendingDeleteItem`
- `confirmationDialog` or `alert` that asks for destructive confirmation
- floating `Add new item` button at the bottom that:
  - creates `character.addEquipmentItem()`
  - stores the new item in selection state
  - pushes the editor immediately

Row content should render:

```swift
VStack(alignment: .leading, spacing: 6) {
    HStack(alignment: .firstTextBaseline, spacing: 8) {
        Text(item.name.isEmpty ? "Unnamed item" : item.name)
            .font(.subheadline.weight(.semibold))
        Spacer()
        Text("ENC \(item.encumbrance)")
            .font(.subheadline)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        Button {
            item.isCurrentlyEquipped.toggle()
        } label: {
            Image(systemName: item.isCurrentlyEquipped ? "checkmark.square.fill" : "square")
        }
        .buttonStyle(.plain)
    }

    if item.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
        Text(item.notes)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .lineLimit(2)
    }
}
```

Keep row cards bordered and compact rather than using plain list rows.

**Step 2: Run a full build**

Run:

```bash
xcodebuild -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: BUILD SUCCEEDED.

**Step 3: Manual smoke test in the simulator**

Verify:

1. Equipment title stays left-aligned and content scrolls beneath the overlay.
2. The top card shows `Max ENC / Current ENC`.
3. Search finds both name and notes, with name results first.
4. Tapping a row pushes the editor.
5. Tapping the checkbox does not push the editor.
6. `Add new item` creates an item and pushes the editor immediately.
7. Trailing swipe delete shows the destructive confirmation and only deletes on `Yes`.
8. List content extends behind the tab bar without a hard edge.

**Step 4: Commit**

```bash
git add RQSheet/EquipmentView.swift RQSheet/EquipmentViewModel.swift RQSheet/EquipmentEditorView.swift
git commit -m "feat: implement equipment tab list and editor flow"
```

### Task 6: Add ENC chip to Summary derived stats and verify the feature end-to-end

**Files:**
- Modify: `RQSheet/StatsOverviewView.swift`
- Modify: `RQSheet/SummaryViewModel.swift`

**Step 1: Add the Summary ENC chip**

Modify the derived stats row in `RQSheet/StatsOverviewView.swift`:

```swift
HStack(spacing: 8) {
    DerivedStatChip(label: "HP", value: viewModel.hitPointsText)
    DerivedStatChip(label: "Healing", value: viewModel.healingRateText)
    DerivedStatChip(label: "Move", value: viewModel.moveText)
    DerivedStatChip(label: "ENC", value: viewModel.encumbranceText)
}
```

Keep the formatting compact so the card still fits on supported widths.

**Step 2: Run targeted tests and then the full test suite**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEquipmentTests -only-testing:RQSheetTests/EquipmentViewModelTests -only-testing:RQSheetTests/SummaryViewModelTests -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: PASS.

Then run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17'
```

Expected: TEST SUCCEEDED.

**Step 3: Request code review**

Use `@requesting-code-review` against the branch/workspace state after tests pass.

Focus review on:

- search ranking behavior
- navigation vs checkbox tap separation
- delete confirmation safety
- schema registration and persistence
- Summary ENC chip accuracy

**Step 4: Final verification and commit**

After addressing any review findings, run:

```bash
git status --short
xcodebuild -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected:

- `git status --short` shows only intended changes before the last commit, then empty after commit
- build succeeds

Commit:

```bash
git add RQSheet/StatsOverviewView.swift RQSheet/SummaryViewModel.swift
git commit -m "feat: add encumbrance summary chip"
```
