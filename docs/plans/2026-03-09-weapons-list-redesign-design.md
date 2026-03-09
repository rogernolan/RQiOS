# Weapons List Redesign Design

- Date: 2026-03-09
- Project: RQSheet
- Scope: Redesign the Combat weapons list to match the app's translucent list/card pattern, support inline disclosure details, and treat weapons as equippable inventory that contribute to encumbrance.

## Goals

1. Replace the current table-like weapons layout with a single compact row per weapon.
2. Match the visual language used by Equipment, Skills, and Magic:
   - translucent rows/cards
   - overlay header treatment
   - content scrolling behind the header and tab bar
   - floating add button at the bottom
3. Support inline disclosure on each weapon row to reveal secondary combat data without leaving the list.
4. Keep tap-to-edit in a sheet and swipe-to-delete with confirmation.
5. Add a persisted equipped state for weapons and include equipped weapon ENC in the character's current encumbrance total.
6. Adjust weapon HP editing so entering Max HP clamps Current HP and fills it from Max HP when Current HP is unset.

## Non-Goals

1. Reworking the hit-location overlay at the top of Combat.
2. Introducing search, sorting controls, or grouping for weapons.
3. Linking weapons to separate equipment records.
4. Adding derived combat calculations beyond the existing displayed values.

## Approved Decisions

### Model naming

Rename `WeaponSkill` to `Weapon` and rename `RQCharacter.weaponSkills` to `RQCharacter.weapons`.

Reasoning:

- the record now represents an equippable object, not just a percentage entry
- keeping one model avoids cross-record sync between Combat and Equipment
- natural or improvised weapons still fit the same single record without requiring an Equipment twin

### Weapon ownership and encumbrance

Weapons remain their own persisted model. They do not reference `CharacterEquipmentItem`.

`RQCharacter.currentEncumbrance` will sum:

- equipped equipment item encumbrance
- equipped weapon encumbrance where the weapon has a non-`nil` `enc`

This keeps Summary and Equipment totals consistent without screen-specific logic.

### Optional range field

Weapons gain a persisted `range` text field. The UI treats blank or whitespace-only range text as absent.

Reasoning:

- range is text-first in RuneQuest usage
- storing it as text matches the current handling of `damage` and `strikeRank`
- some weapons have no range and should omit the field from the expanded view

## List Layout

### Header row

The compact list uses a visible column header row directly above the scrolling list content:

- `Name`
- `%`
- experience check
- `SR`
- `damage`

The header matches the compact row layout so the list reads as a structured table while still using card rows.

### Compact row

Each weapon renders as one translucent compact card with:

- name on the left
- percentage text
- experience checkbox
- strike rank
- damage
- trailing disclosure button on the right-hand side

The row should remain dense enough to scan quickly across many weapons.

### Expanded detail

Tapping the disclosure control animates the same card open below the compact row. The expanded area uses label/data presentation instead of another header row:

- `HP: current/max`
- `ENC: value`
- `Type: value`
- `Range: value` only when range is present
- `Equipped: checkbox`

Missing values display `-`, except `Range`, which is omitted when blank.

Expanded state is local UI state scoped to the Combat screen.

## Interaction Design

### Tap behavior

- tapping the experience checkbox toggles experience and does not open the editor
- tapping the equipped checkbox in the expanded area toggles equipped and updates encumbrance totals
- tapping the disclosure button only expands or collapses the card
- tapping elsewhere on the row opens the add/edit sheet for that weapon

### Delete

Each weapon row supports trailing swipe to reveal delete. Delete uses the same destructive confirmation pattern already used in Equipment, Skills, and Magic:

- alert title: `This cannot be undone`
- buttons: `No` and `Yes`

### Add

A floating bottom button labeled `Add weapon` appears below the list, using the same capsule/material treatment as the other list screens.

## Editor Design

### Presentation

Replace the current add-only form with a reusable sheet editor used for both add and edit.

The editor uses labeled fields for:

- `Name`
- `Base %`
- experience check
- `SR`
- `Damage`
- `Max HP`
- `Current HP`
- `ENC`
- `Type`
- `Range`
- `Equipped`

### Save semantics

- trimmed empty name falls back to `Weapon`
- blank optional numeric fields save as `nil`
- trimmed empty `strikeRank` saves as empty string
- trimmed empty `range` saves as empty string or `nil` in view logic terms and is hidden in the expanded row

### HP rule

When saving from the editor:

- if Max HP is blank, Current HP is saved as entered
- if Max HP is set and Current HP is blank, Current HP is saved as Max HP
- if both are set, Current HP is saved as `min(current, max)`

The model should still clamp invalid persisted values defensively.

## View Architecture

### `CombatView`

`CombatView` should adopt the same structural pattern as Equipment/Magic/Skills:

- top overlay for title and compact weapons header
- `List`-based content with clear row backgrounds
- translucent cards for each weapon row
- bottom add button row
- delete confirmation and sheet presentation at the screen level

### `WeaponRowCard`

Introduce a focused row/card view responsible for:

- compact row layout
- disclosure animation
- expanded detail rendering
- forwarding tap actions without owning persistence logic

### `WeaponEditorView`

Extract the add/edit form into a dedicated reusable editor view instead of embedding it inside `CombatView`.

## Testing Strategy

1. Rename and model tests should cover the new `Weapon` API, including optional combat fields, string strike rank preservation, range persistence, and equipped flag defaults.
2. Character encumbrance tests should prove equipped weapon ENC contributes to `currentEncumbrance` while unequipped weapons and `nil` ENC do not.
3. Source-level Combat view tests should confirm the screen uses:
   - `List`
   - swipe actions
   - sheet-based editor presentation
   - floating add button
   - disclosure-based expanded details
4. Editor tests should cover the Max HP and Current HP save rule.

## Risks

1. Renaming a SwiftData model can impact persistence compatibility. This change should stay narrow and be tested against the existing app schema registration points.
2. Row tap targets can conflict with disclosure and checkbox controls if gesture priority is not explicit.
3. Encumbrance totals are surfaced on multiple screens, so the aggregation rule must stay on `RQCharacter` rather than in a view model.
