# Notes Tab Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a final top-level Notes tab with a single multiline text field whose contents persist on each `RQCharacter`.

**Architecture:** Extend `RQCharacter` with a plain `notes` string, then add a minimal `NotesView` that binds directly to the current character. Update the top-level tab configuration in `ContentView` so Notes appears last and uses the Truth rune asset while preserving the existing single-character app flow.

**Tech Stack:** Swift 6.2, SwiftUI, SwiftData, Observation, `Testing`, xcodebuild.

---

Implementation references: `@test-driven-development`, `@verification-before-completion`, `@requesting-code-review`.

### Task 1: Add persisted notes to the character model

**Files:**
- Modify: `RQSheet/Character.swift`
- Test: `RQSheetTests/CharacterNotesTests.swift`

**Step 1: Write the failing test**

Create `RQSheetTests/CharacterNotesTests.swift` with:

```swift
import Testing
@testable import RQSheet

struct CharacterNotesTests {
    @Test
    func newCharacterStartsWithEmptyNotes() {
        let character = RQCharacter()

        #expect(character.notes == "")
    }
}
```

**Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterNotesTests
```

Expected: FAIL with missing `notes` on `RQCharacter`.

**Step 3: Write minimal implementation**

Modify `RQSheet/Character.swift` to add:

```swift
var notes: String
```

Initialize it with a default empty string in the model initializer.

**Step 4: Run test to verify it passes**

Run the command from Step 2.

Expected: PASS.

**Step 5: Commit**

```bash
git add RQSheet/Character.swift RQSheetTests/CharacterNotesTests.swift
git commit -m "feat: add persisted character notes"
```

### Task 2: Build the Notes tab UI

**Files:**
- Create: `RQSheet/NotesView.swift`
- Modify: `RQSheet/ContentView.swift`
- Modify: `RQSheet/RQSheetApp.swift`

**Step 1: Write the failing test**

If there is an existing view or integration test pattern for top-level tabs, add a focused test for Notes tab visibility. If there is no lightweight existing pattern, skip a new UI test and rely on the model test plus manual verification for this task.

**Step 2: Run test to verify it fails**

Run the targeted test if one was added. Otherwise document that this task will be verified manually because the view uses direct SwiftData binding and has no separate logic seam.

**Step 3: Write minimal implementation**

Create `RQSheet/NotesView.swift` that:

- fetches the current character using the same pattern as the other top-level views
- shows an empty-state message when no character exists
- renders a single multiline `TextField` or `TextEditor` bound to `character.notes`

Modify `RQSheet/ContentView.swift` to:

- use the modern `Tab` API rather than `.tabItem`
- add the new `Notes` tab last
- use the `RuneTruth` asset via the existing tab icon helper

Modify `RQSheet/RQSheetApp.swift` only if the schema registration needs to change for the updated model list.

**Step 4: Run verification**

Run:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:RQSheetTests/CharacterNotesTests
```

Then launch the app or run a simulator build to confirm:

- Notes appears after Equipment
- the tab icon is Truth rune
- editing the multiline field persists

**Step 5: Commit**

```bash
git add RQSheet/NotesView.swift RQSheet/ContentView.swift RQSheet/RQSheetApp.swift RQSheet/Character.swift RQSheetTests/CharacterNotesTests.swift
git commit -m "feat: add notes tab"
```
