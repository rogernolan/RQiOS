# Model/UI Contract Design

## Goal

Update the persisted character and weapon model contract so the UI can represent text-first values, missing combat fields, and a new magic skill group without coercing placeholder defaults into storage.

## Approved Contract

### `RQCharacter`

- `income` becomes `String`
- `move` becomes `Int?`

Rules:

- `income` stores and renders plain text only
- the UI must not append a trailing `L`
- `move == nil` means "no stored value"
- the UI renders `nil` move as a fallback `8` in a grey/secondary style
- real move values render normally

### `WeaponSkill`

- `strikeRank` becomes `String`
- `hpMax` becomes `Int?`
- `hpCurrent` becomes `Int?`
- `enc` becomes `Int?`
- `type` becomes `WeaponType?`

Rules:

- `strikeRank` preserves the entered text instead of forcing numeric normalization
- missing `hpMax`, `hpCurrent`, `enc`, and `type` remain `nil`
- the UI renders each missing optional combat field as `-`

### `SkillGroup`

Add a new persisted case:

- `magic`

Any group title switch or list over `SkillGroup.allCases` must include the new case.

## UI Behavior

### Summary and derived stats

- `SummaryViewModel` exposes move display state without mutating storage
- summary cards render `8` for missing move using secondary styling
- non-nil move values keep existing formatting

### Economy display

- any `income` display uses the stored string as-is
- no renderer appends `"L"`

### Combat weapons

- weapon rows display `strikeRank` as stored text
- `hpMax` and `hpCurrent` render as `max/current` only when both are present
- if either HP value is missing, the HP column renders `-`
- missing `enc` and `type` render as `-`

### Weapon editor

- strike rank input remains a text field and saves raw text
- optional weapon fields submit `nil` when left blank
- the sheet no longer coerces blank optional fields into numeric or enum defaults

## Testing Strategy

Add focused coverage first, then implement:

- `SummaryViewModelTests` for missing-move fallback behavior
- `SkillsViewTests` and related title handling for the new `magic` group
- weapon model tests for optional field storage and `strikeRank` text behavior
- combat/source-level tests for `-` fallbacks and string strike-rank rendering
- summary/source-level tests for grey fallback move rendering if needed

## Scope Boundaries

- no migration or backfill for existing persisted data
- no broader redesign of the character editor
- no changes to unrelated skill, equipment, or magic-page behaviors beyond the new model contract
