# Equipment Tab Design

- Date: 2026-03-07
- Project: RQSheet
- Scope: Reimplement the Equipment tab as a persisted item list with search, edit flow, equipped ENC totals, and Summary derived-stat integration.

## Goals

1. Replace the placeholder Equipment tab with a usable inventory workflow.
2. Keep list browsing fast: dense rows, inline equip toggle, search-first filtering.
3. Make editing explicit by pushing a detail editor instead of editing rows in place.
4. Show ENC load in two places:
   - Equipment header: `Max ENC / Current ENC`
   - Summary derived stats: `ENC max/current`
5. Match existing app chrome:
   - content scrolls under the top title/search treatment
   - content extends behind the tab bar
   - cards use the established bordered compact styling where requested

## Non-Goals

1. Quantity tracking.
2. Categories, tags, costs, or equipment types.
3. Automatic penalties or derived-stat changes from encumbrance.
4. Manual or alphabetical ordering UI in this phase.

## Requirements Locked In

### List row

Each equipment item renders as a bordered compact two-line card:

- first line: `Name`, `ENC`, equipped checkbox
- second line: notes/description in smaller, lighter text if present

Behavior:

- tapping the checkbox only toggles equipped state
- tapping anywhere else on the row pushes the editor
- trailing-edge swipe reveals delete
- delete requires a destructive confirmation modal with a no/yes choice

### Header

The page title is left-justified `Equipment`.

The right side shows a bordered compact card with:

- `Max ENC / Current ENC`

Definitions:

- `Current ENC` = sum of `encumbrance` for all currently equipped items
- `Max ENC` = average of `STR` and `CON`, capped at `STR`

Implementation detail:

- use integer division for the average: `(str + con) / 2`
- cap with `min(str, (str + con) / 2)`

### Search

The search bar sits at the top of the scrolling content, using the same visual language as Skills.

Search matches:

- `name`
- `notes`

Ranking:

1. items whose `name` matches
2. items whose `notes` match but `name` does not

Tie-break:

- preserve insertion order within the same rank

### Editor

Selecting a row pushes a dedicated editor view with labeled fields:

- `Name` - single line
- `ENC` - non-negative integer
- `Description / Notes` - multiline

Save behavior:

- edits persist implicitly as fields change or on dismissal
- there is no explicit save button

### Add flow

A floating bottom button labeled `Add new item`:

- creates a new blank equipment item
- inserts it at the end of the current list order
- immediately pushes the editor for that new item

## Design Options Considered

### Option A (Selected): dedicated SwiftData equipment model on `RQCharacter`

Add a new `@Model` type linked from `RQCharacter`.

Pros:

- clean persistence model for search, editing, and future sorting modes
- no parsing or serialization layer
- low-friction Summary integration

Cons:

- schema update
- more files than a lightweight local-only list

### Option B: transient view-only list derived from strings on `RQCharacter`

Pros:

- no new model type

Cons:

- brittle storage
- poor migration path
- awkward editor and delete behavior

### Option C: dictionary/blob-backed storage on `RQCharacter`

Pros:

- keeps schema surface smaller

Cons:

- weak type safety
- worse testability
- more complicated future ordering and filtering

Selected: **Option A**.

## Data Model

### New model: `CharacterEquipmentItem`

Fields:

- `name: String`
- `encumbrance: Int`
- `notes: String`
- `isCurrentlyEquipped: Bool`
- `sortOrder: Int`
- `character: RQCharacter?`

Rules:

- `encumbrance` is clamped to `>= 0`
- `sortOrder` preserves insertion order
- model naming should stay neutral enough for future manual/alphabetical sorting

### `RQCharacter` additions

- `equipmentItems: [CharacterEquipmentItem]`
- helper for creating a new item with the next `sortOrder`
- helper/computed properties for `currentEncumbrance` and `maxEncumbrance`

Reasoning:

- keeping ENC calculations on the character avoids duplicating business rules between Summary and Equipment
- insertion order remains the default while leaving room for future sort modes

## View Architecture

### `EquipmentView`

Responsibilities:

- fetch the current character
- render empty state or equipment content
- own navigation to the editor
- host the floating add button and delete confirmation

Layout:

- top overlay containing title row and search field
- scrolling list beneath it
- content extends behind tab bar and beneath overlay

### `EquipmentViewModel`

Responsibilities:

- hold `searchText`
- compute filtered and ranked rows
- expose `current/max` header text
- coordinate pending delete state

Reasoning:

- keeps search and ranking logic out of SwiftUI layout
- gives a focused seam for tests

### `EquipmentEditorView`

Responsibilities:

- bind directly to a single `CharacterEquipmentItem`
- provide labeled controls for `name`, `encumbrance`, and `notes`
- use navigation push style, not sheet

## Interaction Details

### Empty state

If no character exists:

- match other tabs and show a short instruction to create a character in Summary

If character exists but has no equipment:

- show the header/search/add controls normally
- show an empty-state message in the list area

### Delete confirmation

Deletion should not happen immediately from the swipe action.

Flow:

1. user swipes and taps delete
2. app presents destructive confirmation
3. `Yes` deletes permanently
4. `No` cancels with no mutation

### Notes rendering

- only render the second line when notes are non-empty after trimming whitespace
- use smaller and lighter styling than the name row

## Summary Integration

The Summary screen derived stats card gains an ENC chip showing:

- label: `ENC`
- value: `max/current`

Reasoning:

- keeps the summary compact
- reflects the user-approved wording for Summary while Equipment header uses `Max ENC / Current ENC`

## Testing Strategy

1. Model tests
- new item gets increasing `sortOrder`
- `encumbrance` clamps to zero
- `currentEncumbrance` sums equipped items only
- `maxEncumbrance` uses `(STR + CON) / 2` capped at `STR`

2. View-model tests
- empty search returns insertion order
- name matches rank ahead of notes-only matches
- ranking preserves insertion order within the same bucket

3. Persistence tests
- in-memory SwiftData container round-trips equipment items on a character

4. Summary tests
- derived stats expose the ENC chip values correctly

## Migration Impact

- additive schema change only
- existing characters start with empty equipment
- no data backfill required

## Deferred Follow-Ups

1. Manual reordering UI
2. Alternate sort modes including alphabetical
3. Equipment categories and tags
4. Cost, rarity, or provenance fields
5. Encumbrance thresholds and penalties
