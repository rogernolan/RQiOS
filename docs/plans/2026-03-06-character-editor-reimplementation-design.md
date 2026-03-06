# Character Editor Reimplementation (Design)

- Date: 2026-03-06
- Project: RQSheet
- Scope: Reimplement the Character Editor opened from Summary with a modular architecture, hybrid collapsible UX, and flexible dice-based stat rolling.

## Goals

1. Rebuild the editor for maintainability and future extension.
2. Preserve auto-save editing flow (no explicit save/cancel).
3. Add full Passions management in the editor (add/edit/delete/reorder).
4. Add portrait editing in the editor.
5. Add dice-based stat generation with direct number entry alternative.
6. Keep dice design flexible for future race-specific defaults.

## Non-Goals

1. Race system implementation in this phase.
2. Persisting custom per-stat dice formulas in this phase.
3. Reworking non-editor pages.

## Selected Architecture

Approach selected: **Feature-split editor module**.

- Keep `CharacterEditorView` as entry/composition view.
- Introduce `@MainActor @Observable` `CharacterEditorViewModel` for editor state and actions.
- Split UI into focused section views and shared row components.
- Keep hybrid UX: one screen with collapsible sections.

## UX and Section Design

The editor remains one scrollable screen with collapsible sections:

1. Identity
- Name, Family, Patron, Date of Birth.
- Portrait editing: change/remove.

2. Characteristics
- STR, CON, SIZ, DEX, INT, POW, CHA.
- Each row supports:
  - direct numeric input
  - dice roll flow
- POW experience check toggle remains here.

3. Combat & Derived
- Move and relevant derived values/fields according to current model edit rules.

4. Social
- Reputation, Honor (description/percent/check), Occupation, SoL.

5. Economy
- Income, Ransom.

6. Passions
- Full CRUD + reorder.
- Persist order via `sortOrder`.

## Dice Rolling Requirements

Stat rows must support two options:

1. Type a number directly.
2. Generate using dice roll.

Supported formula grammar:

- Base: `NdS`
- Optional drop rule:
  - `L` or `l` for drop lowest one die
  - `H` or `h` for drop highest one die
- Optional signed modifier: `+K` or `-K`

Examples:
- `3d6+4`
- `4d6L+1`
- `3d8H-1`
- `2d6`

Interpretation example confirmed:
- `3d8L-1` => roll 3d8, drop lowest die, sum remaining, subtract 1.

### Default Stat Dice Profile (current race)

- SIZ, INT: `2d6+6`
- All others: `4d6L`

## Flexible Dice Engine Design

Use extensible model/service types so race-specific profiles can be added later.

### 1. `DiceExpression`

Represents parsed expression:
- `diceCount: Int`
- `sides: Int`
- `drop: DropRule?` (`.lowest(1)` / `.highest(1)`)
- `modifier: Int`

Responsibilities:
- Parse from string.
- Validate constraints.
- Produce normalized display format.

### 2. `DiceRollResult`

Captures execution details:
- `rolls: [Int]`
- `kept: [Int]`
- `dropped: [Int]`
- `subtotal: Int`
- `modifier: Int`
- `total: Int`

### 3. `DiceRoller` protocol

- Stateless rolling API driven by injected RNG.
- Production implementation + deterministic test implementation.

### 4. `StatRollProfile`

Maps stat identifiers to default expressions.

- Initial profile is the current default character profile.
- UI asks profile for default expression per stat.
- Future races can provide alternate profiles without editor rewrite.

### 5. View model integration

`CharacterEditorViewModel` responsibilities for dice:
- provide default formula per stat via profile
- parse/validate custom formula
- perform roll
- apply result to model through `setCharacteristic(_:to:)`

## Data Flow

1. `CharacterEditorView` owns/observes `CharacterEditorViewModel`.
2. Sections bind to view model fields and actions.
3. View model mutates `RQCharacter` / related models directly (auto-save via SwiftData).
4. Characteristic changes always route through `setCharacteristic` to preserve derived recomputation behavior.
5. Passion reorder updates `sortOrder` and persists through normal context save behavior.

## Error Handling

- Invalid dice expression:
  - inline validation message
  - roll/apply disabled
- Numeric parse failures:
  - default to safe value or block apply
- Portrait load errors:
  - preserve current image
- Passion operations:
  - stable behavior with empty list and reorder edge cases
- Main-actor confinement:
  - all editor state/actions stay on main actor

## Accessibility

- Explicit labels for dice actions and portrait actions.
- Collapsible headers announce expanded/collapsed state.
- Reorder/delete/add controls have meaningful accessibility labels.

## Testing Strategy

1. Dice parser tests
- Valid formula parsing and normalization.
- Invalid formula rejection with reason.

2. Dice roller tests
- Deterministic roll behavior.
- Drop lowest/highest correctness.
- Modifier application correctness.

3. Stat profile tests
- SIZ/INT defaults `2d6+6`.
- Others default `4d6L`.

4. Editor view model tests
- roll/apply mutates expected stat.
- section collapse state transitions.
- passion add/edit/delete/reorder correctness.

5. Integration smoke tests
- Editor loads with existing character.
- Portrait change/remove path.
- Passions management path.

## Migration and Compatibility

- No destructive migration required for this editor reimplementation.
- Existing persisted character model remains compatible.
- Dice engine additions are additive and runtime-only in this phase.

## Open Follow-Up (Future)

- Add race selection and dynamic `StatRollProfile` selection.
- Optionally persist last-used custom dice formula per stat.
- Replace DOB string with structured day/week/season/year model when ready.

