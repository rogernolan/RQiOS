# Summary Page Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ship a card-based Summary page that surfaces high-value at-a-glance character information, adds portrait + identity metadata, and introduces first-class Honor/Passions persistence.

**Architecture:** Keep `StatsOverviewView` as the Summary entry point, but move display logic into a dedicated `@MainActor @Observable` view model so rendering decisions are testable. Extend `RQCharacter` with model helpers for top-4 rune selection (including fixed placeholders when all runes are zero) and add first-class SwiftData models for Honor and Passions. Keep full text editing in `CharacterEditorView` and limit Summary to quick actions.

**Tech Stack:** Swift 6.2, SwiftUI, SwiftData, PhotosUI, `Testing` framework, xcodebuild.

---

Implementation references: `@test-driven-development`, `@verification-before-completion`, `@requesting-code-review`.

## Preconditions

1. Work from a dedicated worktree/branch for this feature.
2. Ensure an iOS simulator is available (commands below assume `iPhone 16`).

### Task 1: Add failing tests for summary rune ranking and placeholder stability

**Files:**
- Create: `RQSheetTests/CharacterSummaryRuneSelectionTests.swift`
- Modify: `RQSheetTests/RQSheetTests.swift` (if needed for shared helpers/import consistency)

**Step 1: Write the failing test**

```swift
import Testing
@testable import RQSheet

struct CharacterSummaryRuneSelectionTests {

    @Test func topSummaryRunesReturnsHighestFourWhenNonZeroValuesExist() {
        let character = RQCharacter()
        character.fireAffinity.setPercentage(72)
        character.airAffinity.setPercentage(51)
        character.moonAffinity.setPercentage(49)
        character.truthAffinity.setPercentage(61)
        character.deathAffinity.setPercentage(19)

        let runes = character.topSummaryRunes()

        #expect(runes.count == 4)
        #expect(runes.map(\ .name) == [.fire, .truth, .air, .moon])
        #expect(runes.allSatisfy { $0.isPlaceholder == false })
    }

    @Test func topSummaryRunesPersistsPlaceholderSetWhenAllRunesAreZero() {
        let character = RQCharacter()
        for affinity in character.allRuneAffinities {
            affinity.setPercentage(0)
        }

        let first = character.topSummaryRunes().map(\ .name)
        let second = character.topSummaryRunes().map(\ .name)

        #expect(first.count == 4)
        #expect(Set(first).count == 4)
        #expect(first == second)
    }

    @Test func topSummaryRunesMarksOnlyFallbackAsPlaceholder() {
        let character = RQCharacter()
        for affinity in character.allRuneAffinities {
            affinity.setPercentage(0)
        }
        let placeholderRunes = character.topSummaryRunes()

        character.fireAffinity.setPercentage(80)
        let realRunes = character.topSummaryRunes()

        #expect(placeholderRunes.allSatisfy { $0.isPlaceholder })
        #expect(realRunes.allSatisfy { $0.isPlaceholder == false })
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterSummaryRuneSelectionTests
```

Expected: FAIL with compile errors such as `Value of type 'RQCharacter' has no member 'topSummaryRunes'`.

**Step 3: Write minimal implementation**

Create model support in `RQSheet/Character.swift`:

```swift
struct SummaryRuneDisplay: Equatable {
    let name: RuneName
    let percentage: Int
    let isPlaceholder: Bool
}

extension RQCharacter {
    var allRuneAffinities: [RuneAffinity] {
        [
            fireAffinity, darknessAffinity, earthAffinity, waterAffinity,
            airAffinity, moonAffinity, manAffinity, beastAffinity,
            fertilityAffinity, deathAffinity, harmonyAffinity, disorderAffinity,
            truthAffinity, IllusionAffinity, stasisAffinity, movementAffinity
        ]
    }

    func topSummaryRunes() -> [SummaryRuneDisplay] {
        let affinities = allRuneAffinities
        if affinities.contains(where: { $0.percentage > 0 }) {
            summaryPlaceholderRuneNames = nil
            return affinities
                .sorted { lhs, rhs in
                    if lhs.percentage == rhs.percentage {
                        return lhs.name.rawValue < rhs.name.rawValue
                    }
                    return lhs.percentage > rhs.percentage
                }
                .prefix(4)
                .map { SummaryRuneDisplay(name: $0.name, percentage: $0.percentage, isPlaceholder: false) }
        }

        if summaryPlaceholderRuneNames?.count != 4 {
            summaryPlaceholderRuneNames = RuneName.allCases.shuffled().prefix(4).map(\ .self)
        }

        return (summaryPlaceholderRuneNames ?? [])
            .compactMap { name in
                affinities.first(where: { $0.name == name })
            }
            .map { SummaryRuneDisplay(name: $0.name, percentage: $0.percentage, isPlaceholder: true) }
    }
}
```

Also add this property on `RQCharacter`:

```swift
var summaryPlaceholderRuneNames: [RuneName]?
```

**Step 4: Run test to verify it passes**

Run same command as Step 2.

Expected: PASS for all tests in `CharacterSummaryRuneSelectionTests`.

**Step 5: Commit**

```bash
git add RQSheet/Character.swift RQSheetTests/CharacterSummaryRuneSelectionTests.swift RQSheetTests/RQSheetTests.swift
git commit -m "test+model: add summary rune selection and placeholder behavior"
```

### Task 2: Add failing tests for Honor and Passions helpers

**Files:**
- Create: `RQSheetTests/CharacterHonorAndPassionTests.swift`
- Modify: `RQSheet/Character.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import RQSheet

struct CharacterHonorAndPassionTests {

    @Test func ensureHonorExistsCreatesDefaultHonorOnce() {
        let character = RQCharacter()

        #expect(character.honor == nil)

        let first = character.ensureHonorExists()
        let second = character.ensureHonorExists()

        #expect(first === second)
        #expect(character.honor === first)
        #expect(first.percentage == 0)
        #expect(first.experienceCheck == false)
    }

    @Test func addPassionAppendsWithStableSortOrderAndClampsPercentage() {
        let character = RQCharacter()

        character.addPassion(description: "Loyalty (Sartar)", percentage: 130)
        character.addPassion(description: "Hate (Lunars)", percentage: -10)

        #expect(character.passions.count == 2)
        #expect(character.passions[0].sortOrder == 0)
        #expect(character.passions[1].sortOrder == 1)
        #expect(character.passions[0].percentage == 100)
        #expect(character.passions[1].percentage == 0)
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterHonorAndPassionTests
```

Expected: FAIL with missing members/types (`honor`, `passions`, `ensureHonorExists`, `addPassion`).

**Step 3: Write minimal implementation**

Create `RQSheet/CharacterHonor.swift`:

```swift
import Foundation
import SwiftData

@Model
final class CharacterHonor {
    var descriptionText: String
    var percentage: Int {
        didSet { percentage = percentage.clampedPercentage }
    }
    var experienceCheck: Bool
    var character: RQCharacter?

    init(descriptionText: String = "", percentage: Int = 0, experienceCheck: Bool = false, character: RQCharacter? = nil) {
        self.descriptionText = descriptionText
        self.percentage = percentage.clampedPercentage
        self.experienceCheck = experienceCheck
        self.character = character
    }
}
```

Create `RQSheet/CharacterPassion.swift`:

```swift
import Foundation
import SwiftData

@Model
final class CharacterPassion {
    var descriptionText: String
    var percentage: Int {
        didSet { percentage = percentage.clampedPercentage }
    }
    var sortOrder: Int
    var character: RQCharacter?

    init(descriptionText: String = "", percentage: Int = 0, sortOrder: Int = 0, character: RQCharacter? = nil) {
        self.descriptionText = descriptionText
        self.percentage = percentage.clampedPercentage
        self.sortOrder = sortOrder
        self.character = character
    }
}
```

Modify `RQSheet/Character.swift`:

```swift
var dateOfBirth: String
var family: String
var patron: String
var portraitData: Data?
var honor: CharacterHonor?
var passions: [CharacterPassion] = []

@discardableResult
func ensureHonorExists() -> CharacterHonor {
    if let honor {
        return honor
    }
    let created = CharacterHonor(character: self)
    honor = created
    return created
}

func addPassion(description: String, percentage: Int) {
    let nextSortOrder = (passions.map(\ .sortOrder).max() ?? -1) + 1
    let passion = CharacterPassion(
        descriptionText: description,
        percentage: percentage.clampedPercentage,
        sortOrder: nextSortOrder,
        character: self
    )
    passions.append(passion)
}
```

Initialize new fields in `RQCharacter.init(...)` with safe defaults.

**Step 4: Run test to verify it passes**

Run same command as Step 2.

Expected: PASS for all tests in `CharacterHonorAndPassionTests`.

**Step 5: Commit**

```bash
git add RQSheet/Character.swift RQSheet/CharacterHonor.swift RQSheet/CharacterPassion.swift RQSheetTests/CharacterHonorAndPassionTests.swift
git commit -m "test+model: add honor and passions entities with character helpers"
```

### Task 3: Wire new models into SwiftData schema and preview containers

**Files:**
- Modify: `RQSheet/RQSheetApp.swift`
- Modify: `RQSheet/ContentView.swift`

**Step 1: Write failing integration test**

Create `RQSheetTests/SummaryPersistenceIntegrationTests.swift`:

```swift
import Testing
import SwiftData
@testable import RQSheet

struct SummaryPersistenceIntegrationTests {
    @Test func canInsertCharacterWithHonorAndPassionsIntoSwiftDataContainer() throws {
        let schema = Schema([
            RQCharacter.self,
            RuneAffinity.self,
            SkillDefinition.self,
            CharacterSkill.self,
            WeaponSkill.self,
            CharacterHitLocation.self,
            CharacterHonor.self,
            CharacterPassion.self,
        ])

        let container = try ModelContainer(for: schema, configurations: .init(isStoredInMemoryOnly: true))
        let context = container.mainContext

        let character = RQCharacter(name: "Arkat")
        character.ensureHonorExists().percentage = 55
        character.addPassion(description: "Loyalty (Companions)", percentage: 70)

        context.insert(character)
        try context.save()

        let fetch = FetchDescriptor<RQCharacter>()
        let results = try context.fetch(fetch)

        #expect(results.count == 1)
        #expect(results[0].honor?.percentage == 55)
        #expect(results[0].passions.count == 1)
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: FAIL if schema wiring or relationship defaults are incomplete.

**Step 3: Write minimal implementation**

Update `RQSheet/RQSheetApp.swift` schema list:

```swift
let schema = Schema([
    RQCharacter.self,
    RuneAffinity.self,
    SkillDefinition.self,
    CharacterSkill.self,
    WeaponSkill.self,
    CharacterHitLocation.self,
    CharacterHonor.self,
    CharacterPassion.self,
])
```

Update `RQSheet/ContentView.swift` preview `modelContainer(for:)` list with `CharacterHonor.self` and `CharacterPassion.self`.

**Step 4: Run test to verify it passes**

Run same command as Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/RQSheetApp.swift RQSheet/ContentView.swift RQSheetTests/SummaryPersistenceIntegrationTests.swift
git commit -m "chore: wire honor and passions into swiftdata schema and previews"
```

### Task 4: Add failing tests for Summary view model presentation logic

**Files:**
- Create: `RQSheet/SummaryViewModel.swift`
- Create: `RQSheetTests/SummaryViewModelTests.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import RQSheet

struct SummaryViewModelTests {

    @Test func derivedStatsExposeExpectedDisplayValues() {
        let character = RQCharacter()
        character.currentHitpoints = 9
        character.maxHitpoints = 12
        character.healingRate = 3
        character.move = 8

        let viewModel = SummaryViewModel(character: character)

        #expect(viewModel.hitPointsText == "9 / 12")
        #expect(viewModel.healingRateText == "3")
        #expect(viewModel.moveText == "8")
        #expect(viewModel.groupBonuses.count == 6)
    }

    @Test func runeRowsMarkPlaceholderStyleOnlyForFallbackRows() {
        let character = RQCharacter()
        for affinity in character.allRuneAffinities {
            affinity.setPercentage(0)
        }

        let fallbackVM = SummaryViewModel(character: character)
        #expect(fallbackVM.topRunes.allSatisfy { $0.isPlaceholder })

        character.fireAffinity.setPercentage(30)
        let realVM = SummaryViewModel(character: character)
        #expect(realVM.topRunes.allSatisfy { $0.isPlaceholder == false })
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/SummaryViewModelTests
```

Expected: FAIL with `Cannot find 'SummaryViewModel' in scope`.

**Step 3: Write minimal implementation**

Create `RQSheet/SummaryViewModel.swift`:

```swift
import Foundation
import Observation

@MainActor
@Observable
final class SummaryViewModel {
    let character: RQCharacter

    init(character: RQCharacter) {
        self.character = character
    }

    var topRunes: [SummaryRuneDisplay] {
        character.topSummaryRunes()
    }

    var hitPointsText: String {
        "\(character.currentHitpoints) / \(character.maxHitpoints)"
    }

    var healingRateText: String {
        "\(character.healingRate)"
    }

    var moveText: String {
        "\(character.move)"
    }

    var groupBonuses: [(name: String, value: Int)] {
        SkillGroup.allCases.map { group in
            (name: title(for: group), value: character.bonus(for: group))
        }
    }

    private func title(for group: SkillGroup) -> String {
        switch group {
        case .agility: return "Agility"
        case .communication: return "Communication"
        case .knowledge: return "Knowledge"
        case .manipulation: return "Manipulation"
        case .perception: return "Perception"
        case .stealth: return "Stealth"
        }
    }
}
```

**Step 4: Run test to verify it passes**

Run same command as Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/SummaryViewModel.swift RQSheetTests/SummaryViewModelTests.swift
git commit -m "test+vm: add summary presentation view model"
```

### Task 5: Implement Summary cards UI with read-only-first interactions

**Files:**
- Modify: `RQSheet/StatsOverviewView.swift`
- Create: `RQSheet/SummaryCard.swift`
- Create: `RQSheet/SummaryPortraitView.swift`
- Create: `RQSheet/SummaryPassionEditorSheet.swift`

**Step 1: Write the failing test**

Add one behavior test to `RQSheetTests/SummaryViewModelTests.swift`:

```swift
@Test func displayFallbackUsesDashForEmptyIdentityFields() {
    let character = RQCharacter(name: "")
    character.dateOfBirth = ""
    character.family = ""
    character.patron = ""

    let viewModel = SummaryViewModel(character: character)

    #expect(viewModel.displayName == "-")
    #expect(viewModel.dateOfBirthText == "-")
    #expect(viewModel.familyText == "-")
    #expect(viewModel.patronText == "-")
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/SummaryViewModelTests/displayFallbackUsesDashForEmptyIdentityFields
```

Expected: FAIL with missing view-model properties.

**Step 3: Write minimal implementation**

Extend `SummaryViewModel`:

```swift
var displayName: String { display(character.name) }
var dateOfBirthText: String { display(character.dateOfBirth) }
var familyText: String { display(character.family) }
var patronText: String { display(character.patron) }

private func display(_ value: String) -> String {
    value.isEmpty ? "-" : value
}
```

Then redesign `StatsOverviewView`:

- Use `ScrollView` with card sections.
- Identity card:
  - portrait image via `SummaryPortraitView`
  - `Change Photo` quick action
  - read-only rows for name, DOB, family, patron
- Top runes card:
  - 2x2 grid
  - each tile shows rune icon, rune name, `%`
  - apply subdued style only when `isPlaceholder == true`
- Derived stats card:
  - HP, healing rate, move
  - six group bonuses
- Honor card:
  - honor percentage + experience check toggle
- Passions card:
  - passion list sorted by `sortOrder`
  - quick `Add Passion` button presenting `SummaryPassionEditorSheet`

Use project style constraints:

- `foregroundStyle()` not `foregroundColor()`
- `clipShape(.rect(cornerRadius:))` not `cornerRadius()`
- `Button` instead of `onTapGesture()`

**Step 4: Run test to verify it passes**

Run command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/StatsOverviewView.swift RQSheet/SummaryCard.swift RQSheet/SummaryPortraitView.swift RQSheet/SummaryPassionEditorSheet.swift RQSheet/SummaryViewModel.swift RQSheetTests/SummaryViewModelTests.swift
git commit -m "feat(summary): implement card-based summary with honor and passions"
```

### Task 6: Add Photos picker integration with desaturated Man rune fallback

**Files:**
- Modify: `RQSheet/StatsOverviewView.swift`
- Modify: `RQSheet/SummaryPortraitView.swift`

**Step 1: Write the failing test**

Add to `RQSheetTests/SummaryViewModelTests.swift`:

```swift
@Test func portraitStateReflectsPresenceOfPortraitData() {
    let character = RQCharacter()
    let vmWithout = SummaryViewModel(character: character)
    #expect(vmWithout.hasPortrait == false)

    character.portraitData = Data([0x00, 0x01])
    let vmWith = SummaryViewModel(character: character)
    #expect(vmWith.hasPortrait == true)
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/SummaryViewModelTests/portraitStateReflectsPresenceOfPortraitData
```

Expected: FAIL with missing `hasPortrait`.

**Step 3: Write minimal implementation**

- Add `hasPortrait` to `SummaryViewModel`.
- Use `PhotosPicker` in `StatsOverviewView` with `selectionBehavior: .default` and `.images` filter.
- Load selected image data with modern async API:

```swift
Task {
    if let data = try await selectedPhotoItem?.loadTransferable(type: Data.self) {
        character.portraitData = data
    }
}
```

- In `SummaryPortraitView`, display portrait from `portraitData` when decodable; otherwise show `Image("RuneMan")` as a desaturated placeholder:

```swift
Image("RuneMan")
    .resizable()
    .renderingMode(.template)
    .foregroundStyle(.secondary)
    .saturation(0)
```

**Step 4: Run test to verify it passes**

Run same command as Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/StatsOverviewView.swift RQSheet/SummaryPortraitView.swift RQSheet/SummaryViewModel.swift RQSheetTests/SummaryViewModelTests.swift
git commit -m "feat(summary): add photos portrait picker with rune fallback"
```

### Task 7: Extend Character editor with DOB/family/patron and Honor edits

**Files:**
- Modify: `RQSheet/CharacterEditorView.swift`

**Step 1: Write the failing test**

Add to `RQSheetTests/CharacterHonorAndPassionTests.swift`:

```swift
@Test func ensureHonorExistsAllowsEditingDescriptionAndPercentage() {
    let character = RQCharacter()
    let honor = character.ensureHonorExists()

    honor.descriptionText = "Clan Honor"
    honor.percentage = 62

    #expect(character.honor?.descriptionText == "Clan Honor")
    #expect(character.honor?.percentage == 62)
}
```

**Step 2: Run test to verify it fails (if honor mutation logic not complete)**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterHonorAndPassionTests/ensureHonorExistsAllowsEditingDescriptionAndPercentage
```

Expected: FAIL if honor model clamps/relationship behavior is incomplete.

**Step 3: Write minimal implementation**

Update `CharacterEditorView` with new editable rows:

- `Date of Birth` text field bound to `character.dateOfBirth`
- `Family` text field bound to `character.family`
- `Patron` text field bound to `character.patron`
- `Honor` description text field bound to `character.ensureHonorExists().descriptionText`
- `Honor %` numeric text field bound to `character.ensureHonorExists().percentage`

Keep existing summary fields and preserve edit-screen-first workflow.

**Step 4: Run test to verify it passes**

Run command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/CharacterEditorView.swift RQSheetTests/CharacterHonorAndPassionTests.swift
git commit -m "feat(editor): add dob family patron and honor editing"
```

### Task 8: Full verification before completion

**Files:**
- Modify: none (verification + optional tiny fixes only)

**Step 1: Run focused tests**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterSummaryRuneSelectionTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterHonorAndPassionTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/SummaryViewModelTests
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: PASS for all four suites.

**Step 2: Run full unit test suite**

Run:
```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS with `** TEST SUCCEEDED **`.

**Step 3: Run SwiftLint if installed**

Run:
```bash
swiftlint
```

Expected: 0 warnings, 0 errors (or command not found; record that explicitly).

**Step 4: Manual UI verification checklist**

Run app and verify:

1. Summary shows cards in approved order.
2. All-zero runes show fixed random placeholder four, slightly greyed.
3. Non-zero rune data switches to top-four true values, non-grey.
4. Portrait picker writes image and persists.
5. Missing portrait shows desaturated Man rune placeholder.
6. Honor toggle updates from Summary.
7. Passions can be added and persist with stable ordering.
8. Editor updates DOB/family/patron/honor and reflects back on Summary.

**Step 5: Final commit**

```bash
git add -A
git commit -m "feat(summary): redesign summary cards with portrait, runes, honor, and passions"
```

