# Skills View Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor the Skills tab to match the Equipment tab styling, add per-section skill creation, allow editing existing skills in a sheet, and support confirmed swipe-to-delete without changing seeded skill data semantics.

**Architecture:** Keep `CharacterSkill` as the persisted row model, add per-character editable metadata for local skill name/group overrides, and introduce a small `SkillsViewModel` plus shared sheet flow to keep CRUD and filtering logic out of the SwiftUI layout. Rebuild `SkillsView` on the same overlay, card, swipe, and confirmation patterns already used by `EquipmentView`.

**Tech Stack:** SwiftUI, SwiftData, Swift Testing, Xcode/xcodebuild

---

### Task 1: Add per-character editable skill metadata

**Files:**
- Modify: `RQSheet/CharacterSkill.swift`
- Test: `RQSheetTests/CharacterSkillTests.swift`

**Step 1: Write the failing tests**

Create `RQSheetTests/CharacterSkillTests.swift`:

```swift
import Testing
@testable import RQSheet

struct CharacterSkillTests {
    @Test
    func displayNameFallsBackToDefinitionUntilCustomNameIsSet() {
        let definition = SkillDefinition(key: "jump", name: "Jump", group: .agility, baseRule: "10")
        let skill = CharacterSkill(definition: definition, successPercentage: 5)

        #expect(skill.displayName == "Jump")

        skill.customName = "Leap"

        #expect(skill.displayName == "Leap")
        #expect(definition.name == "Jump")
    }

    @Test
    func resolvedGroupFallsBackToDefinitionAndCanBeOverridden() {
        let definition = SkillDefinition(key: "scan", name: "Scan", group: .perception, baseRule: "0")
        let skill = CharacterSkill(definition: definition, successPercentage: 0)

        #expect(skill.resolvedGroup == .perception)

        skill.customGroup = .knowledge

        #expect(skill.resolvedGroup == .knowledge)
    }

    @Test
    func setEffectiveValueStillClampsPercentagesForCustomSkills() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "custom", name: "Custom", group: .communication, baseRule: "0")
        let skill = CharacterSkill(character: character, definition: definition, successPercentage: 0)

        skill.setEffectiveValue(140)

        #expect(skill.effectiveValue() == 100)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterSkillTests`

Expected: FAIL with missing `displayName` and `resolvedGroup` members on `CharacterSkill`.

**Step 3: Write minimal implementation**

Update `RQSheet/CharacterSkill.swift` to add:

```swift
    var customName: String
    var customGroup: SkillGroup?
```

Update the initializer to default them to empty/nil, then add:

```swift
    var displayName: String {
        let trimmed = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty == false {
            return trimmed
        }
        return definition?.name ?? "Unknown Skill"
    }

    var resolvedGroup: SkillGroup? {
        customGroup ?? definition?.group
    }
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterSkillTests`

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/CharacterSkill.swift RQSheetTests/CharacterSkillTests.swift
git commit -m "feat: add editable metadata for character skills"
```

### Task 2: Add skill CRUD and search view-model coverage

**Files:**
- Create: `RQSheet/SkillsViewModel.swift`
- Modify: `RQSheet/Character.swift`
- Test: `RQSheetTests/SkillsViewModelTests.swift`

**Step 1: Write the failing tests**

Create `RQSheetTests/SkillsViewModelTests.swift`:

```swift
import Testing
@testable import RQSheet

struct SkillsViewModelTests {
    @Test
    @MainActor
    func searchUsesCustomDisplayNames() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "jump", name: "Jump", group: .agility, baseRule: "0")
        let skill = CharacterSkill(character: character, definition: definition, successPercentage: 15)
        skill.customName = "Leap"
        character.skills.append(skill)

        let viewModel = SkillsViewModel(character: character)
        viewModel.searchText = "lea"

        #expect(viewModel.filteredSkills(for: .agility).map(\.displayName) == ["Leap"])
    }

    @Test
    @MainActor
    func addSkillCreatesCustomSkillInRequestedGroup() {
        let character = RQCharacter()
        let viewModel = SkillsViewModel(character: character)

        let skill = viewModel.addSkill(name: "Battle Lore", percentage: 35, group: .knowledge)

        #expect(character.skills.count == 1)
        #expect(skill.displayName == "Battle Lore")
        #expect(skill.resolvedGroup == .knowledge)
        #expect(skill.effectiveValue() == 35)
    }

    @Test
    @MainActor
    func updateSkillEditsOnlyTheLocalValues() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "scan", name: "Scan", group: .perception, baseRule: "10")
        let skill = CharacterSkill(character: character, definition: definition, successPercentage: 0)
        character.skills.append(skill)
        let viewModel = SkillsViewModel(character: character)

        viewModel.updateSkill(skill, name: "Spot Weakness", percentage: 45, group: .perception)

        #expect(skill.displayName == "Spot Weakness")
        #expect(skill.effectiveValue() == 45)
        #expect(definition.name == "Scan")
    }

    @Test
    @MainActor
    func deleteConfirmationStateRemovesSkillOnConfirm() {
        let character = RQCharacter()
        let definition = SkillDefinition(key: "jump", name: "Jump", group: .agility, baseRule: "0")
        let skill = CharacterSkill(character: character, definition: definition, successPercentage: 5)
        character.skills.append(skill)
        let viewModel = SkillsViewModel(character: character)

        viewModel.requestDelete(skill)
        #expect(viewModel.pendingDeleteSkill === skill)

        viewModel.confirmDelete()

        #expect(viewModel.pendingDeleteSkill == nil)
        #expect(character.skills.isEmpty)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SkillsViewModelTests`

Expected: FAIL with missing `SkillsViewModel`.

**Step 3: Write minimal implementation**

Create `RQSheet/SkillsViewModel.swift` with:

```swift
import Foundation

@MainActor
final class SkillsViewModel {
    let character: RQCharacter
    var searchText = ""
    var pendingDeleteSkill: CharacterSkill?

    init(character: RQCharacter) {
        self.character = character
    }

    func filteredSkills(for group: SkillGroup) -> [CharacterSkill] { ... }
    func addSkill(name: String, percentage: Int, group: SkillGroup) -> CharacterSkill { ... }
    func updateSkill(_ skill: CharacterSkill, name: String, percentage: Int, group: SkillGroup) { ... }
    func requestDelete(_ skill: CharacterSkill) { pendingDeleteSkill = skill }
    func cancelDelete() { pendingDeleteSkill = nil }
    func confirmDelete() { ... }
}
```

Implementation details:
- filter by `resolvedGroup`
- search against `displayName`
- preserve alphabetical ordering by `displayName`
- add a helper on `RQCharacter` to append a new `CharacterSkill` safely if that keeps the view model cleaner
- create custom skill definitions with stable unique keys such as `custom.<UUID>`

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SkillsViewModelTests -only-testing:RQSheetTests/CharacterSkillTests`

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/SkillsViewModel.swift RQSheet/Character.swift RQSheetTests/SkillsViewModelTests.swift RQSheetTests/CharacterSkillTests.swift
git commit -m "feat: add skills view model and custom skill CRUD"
```

### Task 3: Add the shared skill editor sheet

**Files:**
- Create: `RQSheet/SkillEditorView.swift`
- Test: `RQSheetTests/SkillEditorViewTests.swift`

**Step 1: Write the failing tests**

Create `RQSheetTests/SkillEditorViewTests.swift`:

```swift
import Foundation
import Testing
@testable import RQSheet

struct SkillEditorViewTests {
    @Test
    func editorDeclaresNameAndPercentageFields() throws {
        let source = try skillEditorSource()

        #expect(source.contains("TextField(\"Skill name\""))
        #expect(source.contains("TextField(\"%\""))
    }

    @Test
    func editorDisablesSaveForEmptyTrimmedNames() throws {
        let source = try skillEditorSource()

        #expect(source.contains("trimmedName.isEmpty"))
        #expect(source.contains(".disabled(trimmedName.isEmpty)"))
    }

    private func skillEditorSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/SkillEditorView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SkillEditorViewTests`

Expected: FAIL because `RQSheet/SkillEditorView.swift` does not exist yet.

**Step 3: Write minimal implementation**

Create `RQSheet/SkillEditorView.swift` with:
- sheet title
- `Skill name` text field
- `%` numeric text field
- cancel/save toolbar buttons
- local parsing from string to `Int`
- disabled save when trimmed name is empty

Use the same callback shape as `EquipmentEditorView`:

```swift
struct SkillEditorView: View {
    let title: String
    @State private var name: String
    @State private var percentageText: String
    let onSave: (String, Int) -> Void
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SkillEditorViewTests`

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/SkillEditorView.swift RQSheetTests/SkillEditorViewTests.swift
git commit -m "feat: add skill editor sheet"
```

### Task 4: Refactor the skills screen to the equipment-style flow

**Files:**
- Modify: `RQSheet/SkillsView.swift`
- Modify: `RQSheet/SkillsViewModel.swift`
- Modify: `RQSheet/SkillEditorView.swift`
- Test: `RQSheetTests/SkillsViewTests.swift`

**Step 1: Write the failing tests**

Create `RQSheetTests/SkillsViewTests.swift`:

```swift
import Foundation
import Testing
@testable import RQSheet

struct SkillsViewTests {
    @Test
    func skillsViewIncludesPerSectionAddButtons() throws {
        let source = try skillsViewSource()

        #expect(source.contains("Add new skill"))
    }

    @Test
    func skillsViewUsesSwipeDeleteWithUndoWarning() throws {
        let source = try skillsViewSource()

        #expect(source.contains(".swipeActions"))
        #expect(source.contains("This cannot be undone"))
        #expect(source.contains("Button(\"Yes\", role: .destructive)"))
        #expect(source.contains("Button(\"No\", role: .cancel)"))
    }

    @Test
    func skillsRowsUseEquipmentStyleMaterialCards() throws {
        let source = try skillsViewSource()

        #expect(source.contains("Color(.systemBackground).opacity(0.52)"))
        #expect(source.contains("RoundedRectangle(cornerRadius: 12)"))
    }

    private func skillsViewSource() throws -> String {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("RQSheet/SkillsView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SkillsViewTests`

Expected: FAIL because the current skills screen is still a plain list without add buttons, swipe delete, or equipment-style cards.

**Step 3: Write minimal implementation**

Refactor `RQSheet/SkillsView.swift` to:
- introduce `CharacterSkillsContentView` mirroring the `EquipmentView` structure
- hold `@State private var viewModel: SkillsViewModel`
- present `SkillEditorView` via `.sheet(item:)`
- drive delete confirmation from `viewModel.pendingDeleteSkill`
- use an overlay header with:
  - left-aligned `Skills`
  - equipment-style search field
- render each section header with group title, group bonus, and `Add new skill`
- render skill rows as compact material cards with:
  - display name
  - effective percentage
  - inline experience-check toggle
- add trailing swipe delete actions with `allowsFullSwipe: false`

Also add a small `SkillEditorSheet` helper struct mirroring the equipment implementation style.

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SkillsViewTests -only-testing:RQSheetTests/SkillEditorViewTests -only-testing:RQSheetTests/SkillsViewModelTests -only-testing:RQSheetTests/CharacterSkillTests`

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/SkillsView.swift RQSheet/SkillsViewModel.swift RQSheet/SkillEditorView.swift RQSheetTests/SkillsViewTests.swift
git commit -m "feat: refactor skills tab with editor and delete flow"
```

### Task 5: Verify the integrated behavior

**Files:**
- Modify as needed based on failures from previous tasks

**Step 1: Run the focused skill-related test suite**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:RQSheetTests/CharacterSkillTests \
  -only-testing:RQSheetTests/SkillsViewModelTests \
  -only-testing:RQSheetTests/SkillEditorViewTests \
  -only-testing:RQSheetTests/SkillsViewTests
```

Expected: PASS.

**Step 2: Run the broader app test suite**

Run: `xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17'`

Expected: PASS. If unrelated baseline failures remain, capture them explicitly before claiming completion.

**Step 3: Check git status**

Run: `git status --short`

Expected: clean working tree.

**Step 4: Commit final verification fixes if needed**

```bash
git add <updated-files>
git commit -m "test: finalize skills view refactor coverage"
```
