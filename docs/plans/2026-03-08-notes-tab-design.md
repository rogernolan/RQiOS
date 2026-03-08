# Notes Tab Design

- Date: 2026-03-08
- Project: RQSheet
- Scope: Add a final top-level Notes tab that stores a single multiline text field per character and uses the Truth rune as its icon.

## Goals

1. Add a dedicated Notes tab at the top level of the app.
2. Persist notes on each `RQCharacter` through SwiftData.
3. Keep the UI intentionally minimal: one multiline editor and no extra controls.
4. Place the Notes tab last in the tab order and use the existing Truth rune asset.

## Non-Goals

1. Rich text formatting.
2. Multiple note fields or categorized notes.
3. Showing notes on Summary or any other tab.
4. Search, export, or history for notes.

## Requirements Locked In

### Data

- Notes are stored on `RQCharacter`.
- Default value for a new character is an empty string.
- Notes persist implicitly as the user edits the field.

### UI

- Add a new final top-level tab labeled `Notes`.
- Use the Truth rune icon (`RuneTruth`) for the tab.
- The Notes tab contains only a single multiline text entry control bound to `character.notes`.
- If no character exists, match the empty-state language used by other tabs.

## Design Options Considered

### Option A (Selected): store `notes` directly on `RQCharacter` and add a dedicated `NotesView`

Pros:

- smallest data-model change
- straightforward persistence
- matches the current top-level tab architecture
- easy to test

Cons:

- notes remain single-character only until the rest of the app supports multiple-character selection

### Option B: put notes inside the existing character editor

Pros:

- fewer top-level screens

Cons:

- does not satisfy the request for a new tab
- makes notes less discoverable

### Option C: separate note model related to `RQCharacter`

Pros:

- future flexibility for multiple note entries

Cons:

- unnecessary schema and UI complexity for a single text field

Selected: **Option A**.

## Data Model

### `RQCharacter` additions

- `notes: String`

Rules:

- defaults to `""`
- no trimming, formatting, or length enforcement in this phase

Reasoning:

- the app already stores other character-owned editable properties directly on `RQCharacter`
- a plain string keeps persistence and bindings simple

## View Architecture

### `NotesView`

Responsibilities:

- fetch the current character using the same single-character pattern as the other tabs
- render the empty state when no character exists
- bind a multiline text control directly to `character.notes`

Layout:

- title row aligned with the app’s current tab pages
- one bordered multiline editor filling the available content area

### `ContentView`

Responsibilities:

- append `NotesView` as the last tab
- use the Truth rune asset for the tab icon
- keep tab ordering stable for the existing tabs

## Interaction Details

### Editing

- edits save live through the SwiftData model binding
- the text field should support multiple lines and vertical growth/scrolling as needed

### Empty state

- if no character exists, show the same kind of “create a character in Summary” guidance used elsewhere

## Testing Strategy

1. Add a model test proving new characters start with `notes == ""`.
2. Add a view-model or integration-style test only if the Notes tab needs nontrivial logic beyond direct binding.
3. Run the targeted tests for the new model behavior and a broader project test pass if the simulator setup allows it.
