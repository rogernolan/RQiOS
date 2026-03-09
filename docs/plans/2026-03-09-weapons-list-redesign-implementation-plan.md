# Weapons List Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign the Combat weapons list into translucent expandable cards, rename the persisted weapon model, and include equipped weapon ENC in the character's current encumbrance total.

**Architecture:** Replace the old table-like `CombatView` with the same overlay/list/card pattern used by Equipment, Skills, and Magic. Rename `WeaponSkill` to `Weapon`, keep weapon-specific state on that single model, and centralize equipped weapon encumbrance in `RQCharacter.currentEncumbrance` so Summary and Equipment stay correct without screen-specific calculations.

**Tech Stack:** SwiftUI, SwiftData, Swift Testing, Xcode

---

### Task 1: Rename the persisted weapon model surface

**Files:**
- Modify: `RQSheet/Character.swift`
- Modify: `RQSheet/ContentView.swift`
- Modify: `RQSheet/NotesView.swift`
- Modify: `RQSheet/RQSheetApp.swift`
- Create: `RQSheet/Weapon.swift`
- Delete: `RQSheet/WeaponSkill.swift`
- Modify: `RQSheetTests/WeaponSkillTests.swift`
- Modify: `RQSheetTests/SummaryPersistenceIntegrationTests.swift`

**Step 1: Write the failing tests**

Update the source/model tests to use `Weapon` instead of `WeaponSkill` and assert the new API exists.

```swift
struct WeaponTests {
    @Test
    func weaponAllowsMissingCombatFields() {
        let weapon = Weapon(
            name: "Sling",
            damage: "1d6",
            hpMax: nil,
            hpCurrent: nil,
            enc: nil,
            strikeRank: "missile",
            type: nil,
            range: "",
            isEquipped: false
        )

        #expect(weapon.hpMax == nil)
        #expect(weapon.hpCurrent == nil)
        #expect(weapon.enc == nil)
        #expect(weapon.strikeRank == "missile")
        #expect(weapon.range == "")
        #expect(weapon.isEquipped == false)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/WeaponSkillTests`

Expected: FAIL because the codebase still exposes `WeaponSkill` and the tests reference `Weapon`.

**Step 3: Write minimal implementation**

- move the model to `RQSheet/Weapon.swift`
- rename `weaponSkills` to `weapons`
- update all model-container registrations from `WeaponSkill.self` to `Weapon.self`
- keep the existing combat-field clamping behavior during the rename

Minimal target shape:

```swift
@Model
final class Weapon {
    var character: RQCharacter?
    var name: String
    var basePercentage: Int
    var experienceCheck: Bool
    var damage: String
    var hpMax: Int?
    var hpCurrent: Int?
    var enc: Int?
    var strikeRank: String
    var type: WeaponType?
    var range: String
    var isEquipped: Bool
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/WeaponSkillTests -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests`

Expected: PASS with all schema-registration references updated.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet add RQSheet/Character.swift RQSheet/ContentView.swift RQSheet/NotesView.swift RQSheet/RQSheetApp.swift RQSheet/Weapon.swift RQSheetTests/WeaponSkillTests.swift RQSheetTests/SummaryPersistenceIntegrationTests.swift
git -C /Users/rog/Development/RQSheet commit -m "refactor(combat): rename weapon model"
```

### Task 2: Add equipped weapon encumbrance to character totals

**Files:**
- Modify: `RQSheet/Character.swift`
- Modify: `RQSheetTests/CharacterEquipmentTests.swift`
- Modify: `RQSheetTests/SummaryViewModelTests.swift`
- Modify: `RQSheetTests/EquipmentViewModelTests.swift`

**Step 1: Write the failing tests**

Add coverage proving equipped weapons contribute to character encumbrance.

```swift
@Test
func currentEncumbranceIncludesEquippedWeapons() {
    let character = RQCharacter(str: 12, con: 12)
    _ = character.addEquipmentItem(name: "Pack", encumbrance: 2, notes: "", isCurrentlyEquipped: true)
    character.weapons.append(
        Weapon(name: "Broadsword", damage: "1d8+1", enc: 1, isEquipped: true)
    )
    character.weapons.append(
        Weapon(name: "Bow", damage: "1d8", enc: 2, isEquipped: false)
    )

    #expect(character.currentEncumbrance == 3)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEquipmentTests -only-testing:RQSheetTests/SummaryViewModelTests -only-testing:RQSheetTests/EquipmentViewModelTests`

Expected: FAIL because `currentEncumbrance` still sums only equipped equipment items.

**Step 3: Write minimal implementation**

Update `RQCharacter.currentEncumbrance` to aggregate both collections:

```swift
var currentEncumbrance: Int {
    let equipmentTotal = equipmentItems.reduce(into: 0) { total, item in
        if item.isCurrentlyEquipped {
            total += item.encumbrance
        }
    }

    let weaponTotal = weapons.reduce(into: 0) { total, weapon in
        if weapon.isEquipped, let enc = weapon.enc {
            total += enc
        }
    }

    return equipmentTotal + weaponTotal
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterEquipmentTests -only-testing:RQSheetTests/SummaryViewModelTests -only-testing:RQSheetTests/EquipmentViewModelTests`

Expected: PASS with updated totals reflected in Summary and Equipment header text.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet add RQSheet/Character.swift RQSheetTests/CharacterEquipmentTests.swift RQSheetTests/SummaryViewModelTests.swift RQSheetTests/EquipmentViewModelTests.swift
git -C /Users/rog/Development/RQSheet commit -m "feat(combat): count equipped weapons in encumbrance"
```

### Task 3: Add a reusable weapon editor with HP save rules

**Files:**
- Create: `RQSheet/WeaponEditorView.swift`
- Modify: `RQSheetTests/CombatViewTests.swift`
- Create: `RQSheetTests/WeaponEditorViewTests.swift`

**Step 1: Write the failing tests**

Add source-level tests that lock down the editor contract and the Max HP behavior.

```swift
@Test
func weaponEditorSavesBlankCurrentHPAsMaxHPWhenMaxIsPresent() throws {
    let source = try weaponEditorSource()

    #expect(source.contains("if let hpMax"))
    #expect(source.contains("if trimmedCurrentHP.isEmpty"))
    #expect(source.contains("resolvedCurrentHP = hpMax"))
    #expect(source.contains("min(currentHP, hpMax)"))
}
```

Also update `CombatViewTests` to expect sheet-based add/edit instead of the old inline `AddWeaponView`.

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/WeaponEditorViewTests -only-testing:RQSheetTests/CombatViewTests`

Expected: FAIL because `WeaponEditorView.swift` does not exist and `CombatView` still uses `AddWeaponView`.

**Step 3: Write minimal implementation**

Create a reusable sheet editor with add/edit support and save normalization.

Target save logic:

```swift
private func resolvedHPValues(maxText: String, currentText: String) -> (Int?, Int?) {
    let maxValue = optionalIntValue(maxText)
    let currentValue = optionalIntValue(currentText)

    guard let maxValue else {
        return (nil, currentValue)
    }
    guard let currentValue else {
        return (maxValue, maxValue)
    }
    return (maxValue, min(currentValue, maxValue))
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/WeaponEditorViewTests -only-testing:RQSheetTests/CombatViewTests`

Expected: PASS with the editor source and save semantics in place.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet add RQSheet/WeaponEditorView.swift RQSheetTests/WeaponEditorViewTests.swift RQSheetTests/CombatViewTests.swift
git -C /Users/rog/Development/RQSheet commit -m "feat(combat): add reusable weapon editor"
```

### Task 4: Rebuild CombatView as the new translucent expandable list

**Files:**
- Modify: `RQSheet/CombatView.swift`
- Modify: `RQSheetTests/CombatViewTests.swift`

**Step 1: Write the failing tests**

Update `CombatViewTests` to assert the new screen structure.

```swift
@Test
func combatViewUsesExpandableWeaponCardsAndFloatingAddButton() throws {
    let source = try combatViewSource()

    #expect(source.contains("List {"))
    #expect(source.contains("swipeActions(edge: .trailing, allowsFullSwipe: false)"))
    #expect(source.contains("Button(\"Add weapon\")"))
    #expect(source.contains("WeaponRowCard("))
    #expect(source.contains("withAnimation"))
    #expect(source.contains(".sheet(item: $presentedEditor)"))
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests`

Expected: FAIL because `CombatView` still uses a `ScrollView` and plain `HStack` rows.

**Step 3: Write minimal implementation**

Rebuild `CombatView` to:

- keep the hit-location panel above the list
- render a top overlay with title and compact column headers
- use `List` row cards with translucent material backgrounds
- present a trailing disclosure control for inline expansion
- support tap-to-edit, experience toggle, equipped toggle, delete confirmation, and bottom add button

Target row shape:

```swift
private struct WeaponRowCard: View {
    let weapon: Weapon
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    let onSelect: () -> Void
    let onToggleExperience: () -> Void
    let onToggleEquipped: () -> Void
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CombatViewTests`

Expected: PASS with the new list/card structure captured in source tests.

**Step 5: Commit**

```bash
git -C /Users/rog/Development/RQSheet add RQSheet/CombatView.swift RQSheetTests/CombatViewTests.swift
git -C /Users/rog/Development/RQSheet commit -m "feat(combat): redesign weapons list"
```

### Task 5: Verify the integrated flow

**Files:**
- Modify: `RQSheetTests/SummaryPersistenceIntegrationTests.swift`
- Modify: `RQSheetTests/CombatViewTests.swift`
- Modify: `RQSheetTests/WeaponSkillTests.swift`
- Create: `RQSheetTests/WeaponEditorViewTests.swift`

**Step 1: Write the failing integration assertions**

Extend the persistence/integration coverage to prove:

- the app schema uses `Weapon.self`
- equipped weapon ENC survives persistence
- Combat source still includes delete confirmation and editor presentation

```swift
@Test
func equippedWeaponEncumbrancePersistsAcrossModelContainerReload() throws {
    let weapon = Weapon(name: "Broadsword", damage: "1d8+1", enc: 1, isEquipped: true)
    character.weapons.append(weapon)
    #expect(reloadedCharacter.currentEncumbrance == 1)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests -only-testing:RQSheetTests/CombatViewTests -only-testing:RQSheetTests/WeaponSkillTests -only-testing:RQSheetTests/WeaponEditorViewTests`

Expected: FAIL until the rename, encumbrance update, and new editor/list flow all line up.

**Step 3: Run the full targeted suite**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:RQSheetTests/CharacterEquipmentTests \
  -only-testing:RQSheetTests/EquipmentViewModelTests \
  -only-testing:RQSheetTests/SummaryViewModelTests \
  -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests \
  -only-testing:RQSheetTests/CombatViewTests \
  -only-testing:RQSheetTests/WeaponSkillTests \
  -only-testing:RQSheetTests/WeaponEditorViewTests
```

Expected: PASS.

**Step 4: Commit**

```bash
git -C /Users/rog/Development/RQSheet add RQSheetTests/SummaryPersistenceIntegrationTests.swift RQSheetTests/CombatViewTests.swift RQSheetTests/WeaponSkillTests.swift RQSheetTests/WeaponEditorViewTests.swift
git -C /Users/rog/Development/RQSheet commit -m "test(combat): verify redesigned weapons flow"
```
