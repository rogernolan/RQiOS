# Multi-Character Workspace Design

## Goal

Refactor the app from an implicit single-character flow into a list-first experience where users choose a character, enter a dedicated workspace for that character, and can keep multiple characters in storage at once.

## Approved Approach

The app root becomes a `NavigationStack` whose home screen is a character list. Selecting a character, or creating a new one, pushes a character-specific workspace that contains the existing tab interface.

The workspace owns a concrete `RQCharacter` instance. Every tab renders and edits that passed character directly instead of querying `characters.first`.

For v1, the app always opens on the character list after launch. It does not remember the last selected character.

## Screen Structure

### App root

- `ContentView` becomes the shell for a `NavigationStack`
- the root destination is `CharacterListView`
- selecting a character pushes `CharacterWorkspaceView(character:)`

### Character list

- shows all `RQCharacter` records in a vertical scrolling list
- each row contains:
  - portrait thumbnail
  - character name
  - top three runes derived from `topSummaryRunes()`
- tapping a row opens that character's workspace
- supports swipe-to-delete with a destructive confirmation dialog
- has a `Create New Character` button in the top-right
- creating a character inserts a blank seeded character and immediately opens it
- if no characters exist, the list remains the launch screen and shows an empty-state prompt plus the create action

### Character workspace

- contains the existing `TabView` for Summary, Combat, Skills, Runes, Magic, Equipment, and Notes
- receives one concrete `RQCharacter`
- acts as the navigation parent for all tab content
- relies on standard navigation back behavior to return to the character list

## Data And State Flow

### Character selection

- selected-character state is represented by navigation, not a persisted app-wide selection model
- the list screen queries all characters from SwiftData
- the workspace receives the selected `RQCharacter` through navigation
- no cross-launch restoration of the last viewed character is added

### Character creation

- reuse the existing character seeding path to create a blank character
- insert the new character into SwiftData from the list screen
- navigate directly into the new workspace after creation
- multiple blank characters are allowed in v1

### Character deletion

- deletion is only initiated from the character list in this scope
- a swipe action presents a confirmation dialog before removal
- deleting a character removes that `RQCharacter` from SwiftData and relies on the existing model graph relationships for related records
- if the last character is deleted, the app remains on the list screen with its empty state

## Tab Refactor

Each existing top-level tab view changes from:

- query all characters
- derive `characters.first`
- show a "Create a character in Summary..." empty state

to:

- accept `character: RQCharacter`
- render directly from that character
- drop list-level empty states because the workspace only exists for a selected character

This keeps the selected-character contract explicit and removes the current hidden singleton behavior.

## UI Changes

### Summary

- use standard navigation chrome instead of the current custom floating title chip
- navigation title is the selected character's name
- retain a trailing edit action
- keep the rest of the summary content behavior intact unless needed for the container refactor

### Runes

- use a standard navigation title of `Rune Affinities`
- remove the extra in-content titles `Elemental affinities` and `Power Affinities`
- keep the existing rune editor behavior

### Other tabs

- keep their current content patterns where practical
- let their headers behave as screen-local content rather than app-shell chrome
- ensure each tab works correctly when driven by an injected character

## Testing Strategy

Add or update tests to cover the new navigation and multi-character contract:

- character list empty state
- character list row rendering for portrait, name, and top runes
- create action inserts a character and opens its workspace
- delete action requires confirmation
- workspace tabs render the passed character rather than `characters.first`
- regression coverage proving multiple characters can coexist and the selected one is the one shown and edited
- summary navigation title uses the selected character name
- runes screen uses the new single-title presentation

## Scope Boundaries

- no remembered last-selected character
- no importer work in this change
- no disclosure accessory in character rows
- no redesign of the tab content beyond what is needed for explicit character injection and the approved title/header changes
- no special handling for duplicate or blank character names in v1
