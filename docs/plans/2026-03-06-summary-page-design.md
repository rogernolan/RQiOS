# Summary Page Redesign (Design)

- Date: 2026-03-06
- Project: RQSheet
- Scope: Improve Summary page with stronger at-a-glance value while keeping full edits in the editor screen.

## Goals

1. Make Summary useful as a fast read-only dashboard.
2. Add requested character identity and roleplay metadata.
3. Add first-class persistence for Honor and Passions.
4. Keep editing flow centered on `CharacterEditorView`, with minimal quick actions on Summary.

## Non-Goals

1. Full inline editing overhaul on Summary.
2. Refactoring all existing tabs/views.
3. Implementing future structured DOB model (day/week/season/year) in this phase.

## Information Architecture

`StatsOverviewView` becomes a card-based Summary screen in this order:

1. Identity
2. Top Rune Affinities
3. Derived Stats
4. Honor
5. Passions

### 1. Identity Card

- Portrait selected from Photos.
- Neutral placeholder image: desaturated Man rune.
- Read-only rows for:
  - Name
  - Date of Birth (string for now)
  - Family
  - Patron
- Quick action: `Change Photo`.

### 2. Top Rune Affinities Card

- Always render 4 rune entries.
- Normal case: highest four rune percentages.
- Under-developed case (all rune values are zero):
  - Choose 4 random runes once.
  - Persist that set on the character so it remains fixed.
  - Render these entries slightly greyed to indicate placeholder state.
- Greyed styling applies only to placeholders, not all zero-valued runes generally.

### 3. Derived Stats Card

- HP: current/max.
- Healing rate.
- Move.
- Skill-group bonuses:
  - Agility
  - Communication
  - Knowledge
  - Manipulation
  - Perception
  - Stealth

### 4. Honor Card

- Honor behaves like a skill:
  - percentage
  - experience check toggle
- Summary allows quick toggle of experience check.
- Full editing remains in Character editor.

### 5. Passions Card

- Passions are list items with:
  - description
  - percentage
- No experience check for passions.
- Users can add more passions from Summary via `Add Passion` quick action.

## Data Model Design (SwiftData)

### New Models

#### `CharacterHonor` (`@Model`)

- `descriptionText: String` (default `""`)
- `percentage: Int` (clamped `0...100`)
- `experienceCheck: Bool` (default `false`)
- `character: RQCharacter?` (optional relationship)

#### `CharacterPassion` (`@Model`)

- `descriptionText: String` (default `""`)
- `percentage: Int` (clamped `0...100`)
- `sortOrder: Int` (default `0`)
- `character: RQCharacter?` (optional relationship)

### `RQCharacter` Additions

- `dateOfBirth: String = ""`
- `family: String = ""`
- `patron: String = ""`
- `portraitData: Data?`
- `honor: CharacterHonor?`
- `passions: [CharacterPassion] = []`
- `summaryPlaceholderRuneNames: [RuneName]?`

### Character Helpers

- `allRuneAffinities: [RuneAffinity]`
- `topSummaryRunes() -> [SummaryRuneDisplay]`
  - returns top 4 by value when any rune is non-zero
  - otherwise returns persisted placeholder 4, generating once if missing
- `ensureHonorExists()`
- `addPassion(description: String, percentage: Int)`

## UI Component Design

### Summary Shell

- `NavigationStack` retained.
- Main content becomes `ScrollView` + stacked cards.
- Existing title and edit affordance retained.

### Reusable Card

Introduce reusable card shell for consistency:

- header title
- optional header action
- body content slot

Styling should use modern SwiftUI APIs and project conventions:

- prefer `foregroundStyle()`
- `clipShape(.rect(cornerRadius:))`
- no `cornerRadius()` modifier

### Quick Actions

Allowed quick actions on Summary:

- `Change Photo`
- `Add Passion`
- `Toggle Honor experience check`

All richer text edits remain in `CharacterEditorView`.

## Editor Screen Changes

`CharacterEditorView` gains fields for:

- Date of Birth
- Family
- Patron
- Honor description and percentage

Passions may remain list-managed from Summary in this phase.

## Data Flow

1. Summary reads first character as current pattern.
2. Cards compute display using `RQCharacter` helpers.
3. Quick actions mutate model directly and rely on SwiftData binding refresh.
4. Placeholder runes are generated/persisted only when needed.

## Error Handling

- Invalid percentages are clamped in model logic.
- Missing honor is auto-created lazily.
- Empty passion list renders empty state text.
- Photo decode/pick failure preserves previous portrait and fails safely.

## Accessibility

- Explicit labels for quick action buttons.
- Placeholder rune entries indicate provisional status in accessibility value.
- Dynamic Type-friendly layout; avoid hardcoded font sizes.

## Testing Strategy

Add unit tests for core logic:

1. `topSummaryRunes()`
- top-four selection when non-zero values exist
- fixed placeholder generation/persistence when all zero
- placeholder flagging for visual state

2. `ensureHonorExists()`
- creates default honor once
- idempotent behavior

3. `addPassion(description:percentage:)`
- appends with stable `sortOrder`
- clamps percentage

4. Percentage clamping tests
- honor
- passion

## Migration / Compatibility

- Use optional/defaulted properties so existing data remains compatible.
- No destructive migration needed for this phase.
- Future DOB structured model can replace `dateOfBirth` without changing Summary IA.

