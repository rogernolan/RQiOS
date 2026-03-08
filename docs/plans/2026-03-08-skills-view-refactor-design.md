# Skills View Refactor Design

- Date: 2026-03-08
- Project: RQSheet
- Scope: Restyle the Skills tab to match the Equipment tab chrome and cards, add per-section skill creation, allow editing existing skills, and support destructive swipe-to-delete.

## Goals

1. Make the Skills tab visually consistent with Equipment without changing the skill data the app already shows.
2. Add an `Add new skill` action to every skill section.
3. Allow existing skills to be edited through a sheet.
4. Support swipe-to-delete with a destructive confirmation dialog using the approved `This cannot be undone` copy and `Yes` / `No` actions.
5. Preserve existing behavior that matters:
   - section grouping
   - search by skill name
   - category bonus display
   - experience check toggles

## Non-Goals

1. Changing seeded skill JSON content.
2. Reworking skill bonus math or base-rule evaluation.
3. Introducing drag reordering.
4. Changing the single-character selection model used elsewhere in the app.

## Requirements Locked In

### Layout and chrome

- The overall screen should mirror `EquipmentView`:
  - overlay header
  - translucent search field
  - bordered translucent cards
  - content scrolling under the overlay
- Data shown in the list remains the same as today:
  - skill name
  - effective percentage
  - experience check state

### Section actions

- Every skill group header gets an `Add new skill` button.
- Tapping the button opens a sheet scoped to that group.
- The sheet allows editing:
  - skill name
  - effective percentage

### Editing existing skills

- Tapping a skill card opens the same sheet populated with the existing values.
- Existing skills are editable, not read-only.
- Editing must not rename shared seeded definitions for every character.

### Delete flow

- Each skill row gets a trailing swipe-to-delete action.
- Delete must confirm with:
  - title: `This cannot be undone`
  - actions: `No` and `Yes`

## Design Options Considered

### Option A (Selected): keep `CharacterSkill` as the persisted row and add per-character editable metadata

Add local fields on `CharacterSkill` for:
- editable display name override
- editable group override for custom skills

Pros:
- preserves seeded `SkillDefinition` records as shared defaults
- avoids changing names globally when one character edits a skill
- supports both seeded and custom skills with one row model
- keeps existing effective-value logic intact

Cons:
- adds a small amount of fallback logic when choosing display name and group

### Option B: edit `SkillDefinition` directly

Pros:
- minimal new model fields

Cons:
- renaming one skill would mutate shared seeded data
- risks affecting multiple characters
- makes custom-skill ownership ambiguous

### Option C: separate custom-skill model

Pros:
- clean distinction between seeded and custom content

Cons:
- more UI branching
- more persistence and filtering code
- unnecessary complexity for the requested scope

Selected: **Option A**.

## Data Model

### `CharacterSkill` additions

Add per-character fields:
- `customName: String`
- `customGroup: SkillGroup?`

Derived behavior:
- `displayName` resolves to `customName` when non-empty, otherwise `definition?.name`
- `resolvedGroup` resolves to `customGroup` when present, otherwise `definition?.group`

Reasoning:
- seeded skills continue to use `SkillDefinition` as the source of truth by default
- custom skills can exist without requiring a full seeded-definition workflow
- edited seeded skills stay local to the character

### Creating custom skills

New skills will still be stored as `CharacterSkill` entries attached to the current character.

For newly added skills:
- create a lightweight `SkillDefinition` with a unique key, requested name, chosen group, and base rule `0`
- store the chosen name on `customName`
- store the section on `customGroup`
- set the entered percentage through `setEffectiveValue(_:)`

This keeps `effectiveValue()` working through the same path as seeded skills while allowing local editing later.

## View Architecture

### `SkillsView`

Responsibilities:
- fetch the current character
- render the equipment-style header/search/list layout
- own sheet presentation for add/edit
- own delete confirmation state

Layout:
- top overlay with title and search field
- list beneath it with transparent rows and section spacing
- section headers showing:
  - group title
  - category bonus
  - `Add new skill` action

### `SkillsViewModel`

Introduce a dedicated view model similar to `EquipmentViewModel` to hold:
- `searchText`
- pending delete skill
- group-aware filtering helpers
- create/update/delete helpers

Reasoning:
- keeps CRUD and filtering logic out of the SwiftUI body
- gives a stable test seam for add/edit/delete behavior
- matches the project pattern already used for Equipment and Magic

### Skill editor sheet

Add a small reusable sheet view for skill editing with:
- title (`Add Skill` / `Edit Skill`)
- name field
- percentage field
- save action

The sheet is shared for both:
- adding a new skill from a section header
- editing an existing skill from a row tap

## Interaction Details

### List row

Each skill row becomes a card styled like Equipment:
- left side: name and optional secondary context only if needed
- right side: effective `%`
- trailing experience check toggle remains inline and separate from row tap

Behavior:
- tapping the card opens the edit sheet
- tapping the checkbox only toggles `experienceCheck`

### Search

Search behavior stays name-based.

Implementation detail:
- filter against `displayName`, not raw `definition?.name`, so edited and custom skills remain discoverable

### Group rendering

Only show rows whose resolved group matches the section.

Implication:
- custom skills stay in the section where they were created
- edited seeded skills stay in their original group unless explicitly changed by editing `customGroup`

For this phase, the sheet will keep the group fixed to the originating section to avoid accidental cross-section moves.

### Empty states

- If no character exists, keep the existing guidance message.
- If search has no matches in a section, keep the existing `No matches` messaging pattern.

## Validation and Error Handling

- Trim skill names before save.
- Empty saved names fall back to `Unnamed skill` in the UI and should be avoided in the editor by disabling save when the trimmed name is empty.
- Clamp entered percentages with existing percentage rules through `setEffectiveValue(_:)`.
- Deleting a skill removes the `CharacterSkill` row only; it does not touch shared seeded definitions.

## Testing Strategy

1. Model tests:
- edited seeded skill keeps definition name unchanged while exposing the custom display name
- resolved group prefers the custom group when present

2. View-model tests:
- adding a custom skill appends it to the target group with the requested effective percentage
- updating a skill changes local name and percentage only
- deleting a skill removes it from the character after confirmation
- search matches custom display names

3. View source tests:
- `Add new skill` appears in the skills UI
- delete confirmation uses `This cannot be undone`, `Yes`, and `No`
- skills rows use swipe actions and sheet presentation hooks

## Migration and Compatibility

- This is an additive schema change on `CharacterSkill`.
- Existing seeded skills continue to render from their current definitions because new fields default to empty or nil.
- Existing characters require no data backfill.

## Future Follow-Ups

- Allow moving a custom skill between groups.
- Distinguish seeded vs custom skills visually if needed.
- Add sort rules beyond alphabetical display.
