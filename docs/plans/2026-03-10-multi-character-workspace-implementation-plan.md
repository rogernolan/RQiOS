# Multi-Character Workspace Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the app's implicit single-character flow with a character list home screen and a selected-character workspace that supports multiple stored characters.

**Architecture:** `ContentView` becomes a `NavigationStack` rooted at a new `CharacterListView`. Selecting or creating a character pushes a new `CharacterWorkspaceView(character:)` that owns the existing `TabView`, and each tab is refactored to accept an explicit `RQCharacter` instead of querying `characters.first`.

**Tech Stack:** SwiftUI, SwiftData, Swift Testing, Xcode project `RQSheet.xcodeproj`

---

### Task 1: Add the Character List and Workspace Shell

**Files:**
- Create: `RQSheet/CharacterListView.swift`
- Create: `RQSheet/CharacterWorkspaceView.swift`
- Create: `RQSheetTests/CharacterWorkspaceShellTests.swift`
- Modify: `RQSheet/ContentView.swift`

**Step 1: Write the failing test**

Create `RQSheetTests/CharacterWorkspaceShellTests.swift` with source-level assertions for the new shell:

```swift
import Foundation
import Testing
@testable import RQSheet

struct CharacterWorkspaceShellTests {
    @Test
    func contentViewUsesCharacterListNavigationShell() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "RQSheet/ContentView.swift")

        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        #expect(source.contains("NavigationStack"))
        #expect(source.contains("CharacterListView()"))
        #expect(source.contains("CharacterWorkspaceView(character: character)"))
    }
}
```

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterWorkspaceShellTests
```

Expected: FAIL because the new views and navigation shell do not exist yet.

**Step 3: Write minimal implementation**

Implement the new shell:

- `CharacterListView` queries all `RQCharacter` records and exposes a `NavigationLink` per character
- `CharacterWorkspaceView` wraps the current tab bar and accepts `let character: RQCharacter`
- `ContentView` becomes:

```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            CharacterListView()
        }
    }
}
```

and the list links into:

```swift
NavigationLink {
    CharacterWorkspaceView(character: character)
} label: {
    CharacterListRow(character: character)
}
```

**Step 4: Run test to verify it passes**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterWorkspaceShellTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/ContentView.swift RQSheet/CharacterListView.swift RQSheet/CharacterWorkspaceView.swift RQSheetTests/CharacterWorkspaceShellTests.swift
git commit -m "feat: add character workspace shell"
```

### Task 2: Build the Character List UI, Create Flow, and Delete Confirmation

**Files:**
- Modify: `RQSheet/CharacterListView.swift`
- Modify: `RQSheet/SkillSeeder.swift`
- Create: `RQSheetTests/CharacterListViewTests.swift`
- Create: `RQSheetTests/MultiCharacterPersistenceIntegrationTests.swift`

**Step 1: Write the failing tests**

Add source-level list tests for the required UI:

```swift
@Test
func characterListIncludesCreateButtonAndDeleteConfirmation() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appending(path: "RQSheet/CharacterListView.swift")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains("Button(\"Create New Character\")"))
    #expect(source.contains(".swipeActions"))
    #expect(source.contains(".alert(\"Confirm delete\""))
    #expect(source.contains("character.topSummaryRunes().prefix(3)"))
}
```

Add an integration test to prove multiple characters can coexist:

```swift
@Test
@MainActor
func swiftDataCanStoreMultipleCharactersAtOnce() throws {
    let container = try makeInMemoryContainer()
    let context = container.mainContext

    let first = SkillSeeder.createCharacter(in: context)
    first.name = "Ornstal"
    let second = SkillSeeder.createCharacter(in: context)
    second.name = "Selina"

    try context.save()

    let results = try context.fetch(FetchDescriptor<RQCharacter>())
    #expect(results.count == 2)
    #expect(Set(results.map(\.name)) == ["Ornstal", "Selina"])
}
```

**Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterListViewTests -only-testing:RQSheetTests/MultiCharacterPersistenceIntegrationTests
```

Expected: FAIL because the list screen is still missing the required UI and regression coverage.

**Step 3: Write minimal implementation**

Implement in `CharacterListView.swift`:

- `@Environment(\.modelContext)` and `@Query` for all characters
- list row content with thumbnail, name, and top three runes
- toolbar create button that calls `SkillSeeder.createCharacter(in:)` and immediately navigates to the new character
- swipe-to-delete with pending deletion state and confirmation alert

Example row shape:

```swift
HStack(spacing: 12) {
    CharacterRowPortrait(character: character)
    VStack(alignment: .leading, spacing: 6) {
        Text(displayName(for: character))
        CharacterRowRunes(runes: Array(character.topSummaryRunes().prefix(3)))
    }
}
```

If helpful, extract a small `makeInMemoryContainer()` helper inside the new integration test file to avoid repeating schema setup.

**Step 4: Run tests to verify they pass**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterListViewTests -only-testing:RQSheetTests/MultiCharacterPersistenceIntegrationTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/CharacterListView.swift RQSheet/SkillSeeder.swift RQSheetTests/CharacterListViewTests.swift RQSheetTests/MultiCharacterPersistenceIntegrationTests.swift
git commit -m "feat: add character list management"
```

### Task 3: Move the Tab Bar Into the Workspace and Inject the Selected Character

**Files:**
- Modify: `RQSheet/CharacterWorkspaceView.swift`
- Modify: `RQSheet/StatsOverviewView.swift`
- Modify: `RQSheet/CombatView.swift`
- Modify: `RQSheet/SkillsView.swift`
- Modify: `RQSheet/RunesView.swift`
- Modify: `RQSheet/MagicView.swift`
- Modify: `RQSheet/EquipmentView.swift`
- Modify: `RQSheet/NotesView.swift`
- Create: `RQSheetTests/CharacterWorkspaceInjectionTests.swift`

**Step 1: Write the failing test**

Create a source-level test that asserts the tabs now accept a `character` parameter instead of querying `characters.first`:

```swift
@Test
func tabViewsRenderInjectedCharacterInsteadOfFirstQueryResult() throws {
    let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    let files = [
        "RQSheet/StatsOverviewView.swift",
        "RQSheet/CombatView.swift",
        "RQSheet/SkillsView.swift",
        "RQSheet/RunesView.swift",
        "RQSheet/MagicView.swift",
        "RQSheet/EquipmentView.swift",
        "RQSheet/NotesView.swift"
    ]

    for path in files {
        let source = try String(contentsOf: root.appending(path: path), encoding: .utf8)
        #expect(source.contains("let character: RQCharacter"))
        #expect(source.contains("characters.first") == false)
    }
}
```

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterWorkspaceInjectionTests
```

Expected: FAIL because the existing tabs still query `characters.first`.

**Step 3: Write minimal implementation**

Refactor the workspace and tabs so the selected character is explicit:

```swift
struct CharacterWorkspaceView: View {
    let character: RQCharacter

    var body: some View {
        TabView {
            Tab { StatsOverviewView(character: character) } label: { ... }
            Tab { CombatView(character: character) } label: { ... }
            Tab { SkillsView(character: character) } label: { ... }
            Tab { RunesView(character: character) } label: { ... }
            Tab { MagicView(character: character) } label: { ... }
            Tab { EquipmentView(character: character) } label: { ... }
            Tab { NotesView(character: character) } label: { ... }
        }
    }
}
```

For each tab:

- add `let character: RQCharacter`
- remove `@Query private var characters`
- remove list-level empty-state copy that assumes no character exists

**Step 4: Run test to verify it passes**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterWorkspaceInjectionTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/CharacterWorkspaceView.swift RQSheet/StatsOverviewView.swift RQSheet/CombatView.swift RQSheet/SkillsView.swift RQSheet/RunesView.swift RQSheet/MagicView.swift RQSheet/EquipmentView.swift RQSheet/NotesView.swift RQSheetTests/CharacterWorkspaceInjectionTests.swift
git commit -m "refactor: inject selected character into workspace tabs"
```

### Task 4: Convert Summary and Runes to Standard Navigation Titles

**Files:**
- Modify: `RQSheet/StatsOverviewView.swift`
- Modify: `RQSheet/RunesView.swift`
- Modify: `RQSheetTests/StatsOverviewViewTests.swift`
- Create: `RQSheetTests/RunesViewTests.swift`

**Step 1: Write the failing tests**

Add a summary title test:

```swift
@Test
func summaryUsesCharacterNameAsNavigationTitle() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appending(path: "RQSheet/StatsOverviewView.swift")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains(".navigationTitle(character.name"))
    #expect(source.contains("headerRow") == false)
}
```

Add a runes title test:

```swift
@Test
func runesViewUsesSingleNavigationTitle() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appending(path: "RQSheet/RunesView.swift")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains(".navigationTitle(\"Rune Affinities\")"))
    #expect(source.contains("Text(\"Elemental affinities\")") == false)
    #expect(source.contains("Text(\"Power Affinities\")") == false)
}
```

**Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/StatsOverviewViewTests -only-testing:RQSheetTests/RunesViewTests
```

Expected: FAIL because Summary still uses the custom chip header and Runes still has two in-content titles.

**Step 3: Write minimal implementation**

In `StatsOverviewView.swift`:

- remove the custom `headerRow` overlay
- promote the edit control into `.toolbar`
- set the navigation title from the selected character name

In `RunesView.swift`:

- add `.navigationTitle("Rune Affinities")`
- remove the `Elemental affinities` and `Power Affinities` text labels

**Step 4: Run tests to verify they pass**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/StatsOverviewViewTests -only-testing:RQSheetTests/RunesViewTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/StatsOverviewView.swift RQSheet/RunesView.swift RQSheetTests/StatsOverviewViewTests.swift RQSheetTests/RunesViewTests.swift
git commit -m "refactor: use standard navigation titles for summary and runes"
```

### Task 5: Verify the Full Workspace Flow Against Existing Tab Behavior

**Files:**
- Modify: `RQSheetTests/MagicViewTests.swift`
- Modify: `RQSheetTests/SkillsViewTests.swift`
- Modify: `RQSheetTests/EquipmentViewTests.swift`
- Modify: `RQSheetTests/NotesViewTests.swift`
- Modify: `RQSheetTests/CombatViewTests.swift`
- Modify: `RQSheetTests/SummaryPersistenceIntegrationTests.swift`

**Step 1: Write the failing tests**

Update existing source-level tests so they assert the old singleton empty-state copy is gone from workspace tabs:

```swift
#expect(source.contains("Create a character in Summary") == false)
#expect(source.contains("let character: RQCharacter"))
```

Add one integration-level regression to `SummaryPersistenceIntegrationTests.swift` to confirm edits can remain scoped to multiple stored characters:

```swift
@Test
@MainActor
func multipleStoredCharactersRetainIndependentNames() throws {
    let container = try makeInMemoryContainer()
    let context = container.mainContext

    let first = RQCharacter(name: "Beriqet")
    let second = RQCharacter(name: "Davelia")
    context.insert(first)
    context.insert(second)
    try context.save()

    second.name = "Voraneva"
    try context.save()

    let results = try context.fetch(FetchDescriptor<RQCharacter>())
    #expect(Set(results.map(\.name)) == ["Beriqet", "Voraneva"])
}
```

**Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CombatViewTests -only-testing:RQSheetTests/SkillsViewTests -only-testing:RQSheetTests/MagicViewTests -only-testing:RQSheetTests/EquipmentViewTests -only-testing:RQSheetTests/NotesViewTests -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: FAIL because the existing tests still assume the old top-level shell and empty-state copy.

**Step 3: Write minimal implementation**

Update the tests and any remaining UI glue so all workspace tabs compile and behave under the new explicit-character container. Do not broaden the scope beyond fixing regressions created by the multi-character refactor.

**Step 4: Run tests to verify they pass**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CombatViewTests -only-testing:RQSheetTests/SkillsViewTests -only-testing:RQSheetTests/MagicViewTests -only-testing:RQSheetTests/EquipmentViewTests -only-testing:RQSheetTests/NotesViewTests -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheetTests/MagicViewTests.swift RQSheetTests/SkillsViewTests.swift RQSheetTests/EquipmentViewTests.swift RQSheetTests/NotesViewTests.swift RQSheetTests/CombatViewTests.swift RQSheetTests/SummaryPersistenceIntegrationTests.swift
git commit -m "test: cover multi-character workspace flow"
```

### Task 6: Final Verification

**Files:**
- Modify: none
- Test: `RQSheetTests`

**Step 1: Run the focused suite**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RQSheetTests/CharacterWorkspaceShellTests -only-testing:RQSheetTests/CharacterListViewTests -only-testing:RQSheetTests/MultiCharacterPersistenceIntegrationTests -only-testing:RQSheetTests/CharacterWorkspaceInjectionTests -only-testing:RQSheetTests/StatsOverviewViewTests -only-testing:RQSheetTests/RunesViewTests -only-testing:RQSheetTests/CombatViewTests -only-testing:RQSheetTests/SkillsViewTests -only-testing:RQSheetTests/MagicViewTests -only-testing:RQSheetTests/EquipmentViewTests -only-testing:RQSheetTests/NotesViewTests -only-testing:RQSheetTests/SummaryPersistenceIntegrationTests
```

Expected: PASS for all targeted tests.

**Step 2: Run a broader regression pass**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS for the full `RQSheetTests` suite.

**Step 3: Inspect git state**

Run:

```bash
git status --short
```

Expected: only the intentional implementation changes for this feature remain.

**Step 4: Commit any final test-only adjustments**

```bash
git add -A
git commit -m "chore: verify multi-character workspace refactor"
```
