# Magic Page Design

## Goal

Implement the Magic tab as a searchable, editable spell management screen with two grouped sections: Spirit Magic and Rune Spells. The screen should follow the same visual and interaction patterns as the Equipment page, while adding character-level magic point and rune point controls in the section headers.

## Data Model

### CharacterSpell

Add a new SwiftData model named `CharacterSpell` with these fields:

- `name: String`
- `points: Int`
- `page: String`
- `kind: SpellKind`
- `sortOrder: Int`
- `character: RQCharacter?`

Rules:

- `points` is clamped to `>= 0`
- `sortOrder` preserves insertion order within the character
- `kind` is a persisted enum with two cases: `spiritMagic` and `runeSpell`

### RQCharacter additions

Add these persisted properties to `RQCharacter`:

- `spells: [CharacterSpell] = []`
- `currentMagicPoints: Int`
- `maxMagicPoints: Int`
- `runePoints: Int`

Rules:

- `maxMagicPoints` defaults to `pow`
- `currentMagicPoints` defaults to `maxMagicPoints`
- `runePoints` defaults to `3`
- `currentMagicPoints` is clamped to `0...maxMagicPoints`
- `maxMagicPoints` is recalculated whenever `pow` changes
- if `pow` reduces `maxMagicPoints`, `currentMagicPoints` is clamped down to the new maximum
- Spirit Magic casting percentage is display-only and always computed as `5 * pow`

### Character helpers

Add focused helpers on `RQCharacter` for:

- adding a spell with correct `sortOrder`
- filtering spells by `kind`
- recalculating magic points after POW changes

Keep these narrow and consistent with the existing equipment helpers.

## UI Structure

### Overall page

The Magic tab should replace the placeholder with a real screen using the same structural pattern as the Equipment page:

- rune background using `RuneMagic`
- overlay header at the top
- search bar below the title
- scrolling content extending under the title, search bar, and tab bar
- translucent list cards so the background rune remains visible

### Header

The page header contains:

- left-aligned title: `Magic`
- no additional page-level chip or button
- shared search bar immediately below the title row

Search applies across all spells on the page.

## Section Design

The page content is a single scrolling list containing two grouped sections in fixed order:

1. `Spirit Magic`
2. `Rune Spells`

Each section header appears inside the scrolling content and includes:

### Spirit Magic header

- left-aligned section title: `Spirit Magic`
- display-only casting percentage shown after the title: `Casting % <value>`
- right-aligned editable current/max magic points control
- trailing `Add new spell` button

Magic points header control behavior:

- shows `current/max`
- `current` is editable inline
- `max` is display-only
- current value is clamped immediately into `0...max`

### Rune Spells header

- left-aligned section title: `Rune Spells`
- right-aligned editable rune points control
- trailing `Add new spell` button

Rune points behavior:

- editable inline integer field
- clamped to `>= 0`

## Spell Rows

Each spell is shown as a compact bordered card, visually consistent with equipment rows.

Layout:

- first line: spell name on the left, points on the right
- second line: page in smaller lighter text

Behavior:

- tapping the row opens the spell editor sheet in edit mode
- trailing swipe reveals delete
- delete requires confirmation with the same irreversible warning pattern used on Equipment

Display fallbacks:

- blank name displays as `Unnamed spell`
- blank page hides the second line entirely rather than showing a placeholder

## Search

The page includes a shared search bar at the top.

Search behavior:

- searches across both sections
- matches against `name` and `page`
- name matches rank ahead of page matches
- preserve insertion order within equal-rank results
- sections remain separate even when filtered
- if a section has no matches, show a section-local empty state rather than removing the section header entirely

Empty states:

- no spells at all: each section shows `No spells yet`
- active search with no matches in a section: show `No matches`

## Spell Editor

Use a shared bottom sheet editor for both spell types, matching the equipment/passions/weapons pattern.

Structure:

- `NavigationStack`
- `Form`
- explicit `Cancel` and `Save`

Fields:

- `Name`
- `Points`
- `Page`

Behavior:

- adding does not create a persisted blank spell until `Save`
- editing uses a local draft and only persists on `Save`
- `Points` accepts only non-negative integer input

Titles:

- `Add Spirit Magic`
- `Edit Spirit Magic`
- `Add Rune Spell`
- `Edit Rune Spell`

## Architecture

### View model

Create a dedicated `MagicViewModel` to own:

- current search text
- visible spirit spells
- visible rune spells
- draft add/edit state for sheets
- pending delete target
- header display values
- update methods for character-level magic fields

This keeps the SwiftUI view thin and mirrors the Equipment implementation.

### Persistence wiring

Add `CharacterSpell` to:

- app schema in `RQSheetApp.swift`
- preview schema in `ContentView.swift`

## Testing Strategy

### Model tests

Add coverage for:

- spell insertion order
- point clamping
- rune point defaults and clamping
- magic point defaults and clamping
- POW recalculating max magic points

### View model tests

Add coverage for:

- grouping by spell kind
- search ranking by name over page
- insertion order preserved within section
- add/edit/delete flows
- overflow and display formatting for magic point controls if any warning states are introduced later

### UI tests

Add focused UI coverage for:

- opening the Magic tab
- presenting add spell sheets from each section
- tapping a spell row to edit it
- visibility of section header controls
- basic search filtering behavior

## Deferred

Not included in this design:

- spell descriptions beyond `page`
- alphabetical/manual ordering controls
- point-spend validation between spells and available pools
- summary-screen magic chips or cross-screen integrations
- separate spell pages per magic system
