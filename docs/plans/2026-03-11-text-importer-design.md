# Text Importer Design

## Goal

Add a paste-based text importer for RQ characters that lives in `Settings` under the existing `More` popup, parses tolerant `.txt` character sheets like Ornstal/Selina, shows a pre-save review report, and always creates a new character.

## Entry Point

`Settings` becomes a fourth destination in the existing workspace `More` popup and uses the `RuneDisorder` icon.

The importer UI lives inside that `Settings` screen.

## User Flow

1. User opens a character workspace.
2. User taps `More`.
3. User selects `Settings`.
4. User pastes raw character text into a large text field.
5. User taps `Import`.
6. App parses the pasted text into an in-memory import result.
7. App shows a review summary screen with per-section R/Y/G status.
8. If the importer found a candidate character name, the app prompts for the final name immediately before save.
9. User taps `Save` or `Cancel`.
10. `Save` always creates a new character and switches the workspace to it.
11. `Cancel` discards the parsed result and creates nothing.

There is no hard completeness gate in v1. The report is the warning; the user decides whether to continue.

## Parsing Approach

The parser is section-oriented and tolerant rather than template-strict.

### Phase 1: Normalize

Before section parsing, normalize the pasted text:

- unify line endings
- trim trailing whitespace
- collapse repeated spaces where safe
- strip obvious badge noise such as `Microbadge: Glorantha fan: ...`
- treat placeholders like `___`, `--%`, `##`, blank ranges, and similar markers as missing values
- preserve original text for later note capture

### Phase 2: Detect Sections

Split the document into major sections using heading names and layout cues, not exact formatting.

Recognized sections:

- character info
- characteristics
- runes
- passions
- combat header / armor data
- weapons
- skills by group
- rune magic
- spirit magic
- equipment
- trailing prose

Examples like Selina and Davelia show why this has to be tolerant:

- headings may be uppercase, title case, or omitted
- line spacing varies
- placeholder values appear inline
- extra prose can appear before passions or after structured content

### Phase 3: Parse Each Section With Small Parsers

Each section gets dedicated line parsers:

- attributes: `STR: 12`
- elemental runes: `Water: 65 [ ]`
- paired runes: `Harmony | Disorder`
- passions: `Loyalty (House): 60%`
- skills: grouped lines like `Bargain 85% [ ]`
- weapons: table-like rows with SR / hit / damage / range / HP
- rune spells: spell name plus points in parentheses
- spirit magic: same pattern, plus MP values where available
- equipment: freeform lines under `Equipment`

This is intentionally layered rather than relying on one large regex.

## Data Mapping

### Character Info

Import:

- name
- family
- patron house
- original house when present, folded into available identity fields or notes only if needed later
- birth/date text
- occupation
- reputation
- SoL
- income
- ransom
- first cult as main cult
- remaining cults appended into `worships`

Ignore for v1:

- personality blurbs
- front-loaded prose
- freeform descriptive lines in the middle of structured sections

### Attributes

Import all seven:

- STR
- CON
- SIZ
- DEX
- INT
- POW
- CHA

### Runes

Import:

- elemental runes
- paired power runes

If the importer fails to map the full expected rune set, the runes summary is red.

### Passions

Import into `CharacterPassion`.

Passions have their own summary row.

Summary rules match equipment:

- green if some passions imported
- yellow if none

### Skills

Import grouped skills using the group header from the source text.

Rules:

- if the source group maps to an existing app skill grouping, import into that grouping
- if the skill name already exists, update/create the corresponding `CharacterSkill`
- if the skill name does not exist, create a custom skill with that name in the parsed group
- if the source group does not map to an app grouping, the skills summary becomes red
- placeholders and blank entries are skipped and the seeded defaults remain

This preserves support for user-edited/custom skills without requiring every imported skill name to exist in the seeded JSON.

### Equipment And Weapons

Equipment and weapons share one review row: `Equipment`.

Import:

- freeform equipment entries into `CharacterEquipmentItem`
- weapon table rows into `Weapon`
- armor text into equipment/freeform entries rather than calculated combat fields

Combat-derived stats are not imported:

- hit points
- current HP
- damage bonus
- healing rate
- strike ranks

Those are calculated or otherwise out of scope for v1.

### Magic

Import:

- rune spells
- spirit magic spells
- rune points where present
- current magic points if present

Fallback:

- if current MP is missing or placeholder, set it to max MP

### Leftover Prose

Only substantial freeform text after the last recognized structured section gets appended verbatim to `notes`.

Inline stray prose between structured sections is ignored.

This keeps Davelia/Ornstal-style backstory while avoiding Selina-style mid-sheet noise polluting notes.

## Review Summary

The review screen shows an R/Y/G list with these rows:

- Character info
- Attributes
- Runes
- Skills
- Equipment
- Magic
- Passions

Rules:

- Character info: green if all key identity fields parsed, yellow if some, red if none
- Attributes: green if all seven parsed, red otherwise
- Runes: green if all expected rune values parsed, red otherwise
- Skills: green if all recognized cleanly, yellow if partial, red if none or if a source group is unsupported
- Equipment: green if some equipment/weapons/armor imported, yellow if none
- Magic: green if some magic imported, yellow if none
- Passions: green if some imported, yellow if none

## Name Prompt

If the parser finds a candidate name, saving is interrupted by a final naming prompt just before persistence.

Behavior:

- prefill the prompt with the parsed name
- allow the user to edit it
- if the parsed name is empty, skip the prompt and keep the current blank/default name behavior unless implementation decides a save-time name is mandatory later

This keeps the parser’s best guess while still letting the user correct OCR-ish or formatting issues before the record is created.

## Error Handling

V1 should prefer graceful partial import over rejection.

- malformed lines inside a recognized section are skipped
- unknown placeholders are treated as missing
- unsupported skill groups mark the skills row red
- unsupported individual skill names create custom skills if the group is valid
- parsing never mutates persistence directly; it produces an in-memory result first

## Architecture

Recommended structure:

- `Settings` view in workspace extras
- importer paste screen
- importer parser / normalization layer
- import review view model
- import review screen
- persistence applier that converts parsed data into a new `RQCharacter`

The parser should return both parsed values and coverage/provenance metadata so the review summary is computed from real evidence rather than heuristics after the fact.

## Testing

Coverage should include:

- section detection against Ornstal, Selina, Beriqet, and Davelia examples
- tolerant parsing of identity, attributes, runes, passions, skills, weapons, equipment, and spells
- trailing prose capture only after the last structured section
- custom skill creation for unmatched but valid grouped skills
- red skills status when a source group cannot map to an app grouping
- save flow always creating a new character
- parsed-name prompt behavior before save
- workspace switching to the imported character after save

