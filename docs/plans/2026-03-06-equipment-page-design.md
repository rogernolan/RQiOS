# Equipment Page (Design)

- Date: 2026-03-06
- Project: RQSheet
- Scope: Create a first-class Equipment tab with persisted inventory items, row-level editors, search, ENC totals, and Summary integration.

## Goals

1. Replace placeholder Equipment screen with a usable inventory workflow.
2. Track encumbrance totals with emphasis on equipped load.
3. Keep row list dense and readable while preserving edit depth through a detail editor.
4. Add equipped/total ENC visibility to Summary Derived Stats.
5. Match existing app interaction patterns (search, scroll under overlays, tab behavior).

## Non-Goals

1. Quantity tracking in this phase.
2. Equipment categories or weight units beyond simple integer ENC.
3. Automatic ENC effects on derived characteristics in this phase.
4. Multi-character selection changes.

## Approach Options Considered

### Option A (Selected): Dedicated `CharacterEquipmentItem` SwiftData model

- Add a new model linked to `RQCharacter`.
- Persist each equipment row as an independent record.
- Pros:
  - clean data shape for CRUD and search
  - future-proof for categories, costs, tags
  - straightforward testability
- Cons:
  - schema change and migration surface

### Option B: Store equipment as encoded text/blob on `RQCharacter`

- Pros: fewer model files.
- Cons: poor queryability, brittle migration path, weaker validation and UX.

### Option C: Reuse `WeaponSkill` for equipment

- Pros: no schema addition.
- Cons: semantic mismatch, technical debt, mixed concerns.

Selected: **Option A**.

## Data Model Design

### New Model: `CharacterEquipmentItem` (`@Model`)

Fields:
- `name: String`
- `encumbrance: Int` (clamped to `>= 0`)
- `isEquipped: Bool`
- `notes: String`
- `sortOrder: Int`
- `character: RQCharacter?` (optional relationship)

### `RQCharacter` Additions

- `equipmentItems: [CharacterEquipmentItem] = []`
- helper for adding an item with next `sortOrder`

## Equipment Page UX

## Top strip

- Show two values:
  - `Equipped ENC`
  - `Total ENC`
- Render at top of page as compact chips/summary row.

## Search

- Add search bar matching Skills style.
- Match across:
  - `name`
  - `notes`
- Ranking priority:
  1. name match
  2. notes-only match
- Within same rank, sort by current display order (`sortOrder`) then name.

## List rows

Each row shows:
- Primary line: `Name`, `ENC`, `equipped` toggle
- Secondary line: `notes` only if non-empty

Behavior:
- Row tap pushes editor screen (`NavigationStack` + `NavigationLink`).
- Support delete and reorder.

## Row editor screen

Editable fields:
- Name
- ENC
- Equipped toggle
- Notes

No quantity field.

## Add flow

- `+` action at list level creates a new item and navigates to that item editor.

## Scrolling and chrome behavior

- Equipment content should scroll beneath title/search overlay and behind tab bar, consistent with Summary/Skills behavior.
- Hide indicators and use safe-area treatment matching other tabs.

## Summary Integration

In Summary `Derived Stats` card:
- Add ENC chip showing `equipped/total`.
- Example display: `ENC 7 / 19`.

## Data Flow

1. Equipment tab reads first character from `@Query` (existing app pattern).
2. View computes sorted/filtered list from `character.equipmentItems`.
3. CRUD and field edits mutate SwiftData models directly.
4. ENC totals derive from current list state.
5. Summary reads the same character-derived ENC totals.

## Validation and Error Handling

- Clamp ENC to non-negative values.
- Empty name allowed initially (new item scaffold), but editor placeholder should prompt naming.
- Notes optional.
- If no character exists, show guidance message (same pattern as other tabs).

## Accessibility

- Search field has explicit placeholder and supports Dynamic Type.
- Equipped toggle has clear label.
- Row editor controls have descriptive labels.

## Testing Strategy

1. Model and helper tests:
- add item assigns stable incremental `sortOrder`
- ENC clamping non-negative

2. Equipment view model/filter logic tests:
- name matches rank above notes-only matches
- empty search returns full ordered list

3. Summary integration tests:
- ENC totals reflect equipped and total values accurately

4. Persistence smoke:
- inserting character with equipment items round-trips in in-memory container

## Migration and Compatibility

- Additive model/schema change only.
- Existing characters default to empty `equipmentItems`.
- No destructive migration expected in this phase.

## Future Follow-Ups

- Categories and tags
- Currency/cost fields
- ENC thresholds and derived penalties
- Bulk equip/unequip actions
