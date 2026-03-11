# Text Importer Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a settings-hosted paste importer that parses tolerant RQ text sheets, shows a review summary, prompts for a parsed name before save, and always creates a new character that becomes the active workspace character.

**Architecture:** Add `Settings` to the existing workspace extras popup, then build the importer as a three-stage flow: paste input, parser result + review model, persistence apply. Keep parsing pure and in-memory until the user confirms save. Use source-example-driven tests to lock down section detection and tolerant line parsing before UI integration.

**Tech Stack:** SwiftUI, SwiftData, current `RQCharacter` model graph, Swift Testing source-level and parser tests, existing workspace navigation shell.

---

### Task 1: Add the Settings destination to workspace extras

**Files:**
- Modify: `/Users/rog/Development/RQSheet/RQSheet/CharacterWorkspaceView.swift`
- Test: `/Users/rog/Development/RQSheet/RQSheetTests/CharacterWorkspaceChromeTests.swift`

**Step 1: Write the failing test**

Add expectations that:

- `ExtrasDestination` includes `settings`
- the settings destination title is `Settings`
- the settings destination rune name is `RuneDisorder`
- `CharacterMoreTabView` routes `.settings`

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=35D3E526-9398-48CC-AB55-F4927A5E103A' -only-testing:RQSheetTests/CharacterWorkspaceChromeTests`

Expected: fail because `settings` destination is not present yet. If the simulator harness stalls, run a source-level file test path or fall back to `xcodebuild build` after verifying the new expectations are absent.

**Step 3: Write minimal implementation**

- add `.settings` to `ExtrasDestination`
- return `Settings` title
- return `RuneDisorder` rune asset
- route the settings destination to a new placeholder view

**Step 4: Run test to verify it passes**

Run the same command and confirm the expectation now matches.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/CharacterWorkspaceView.swift /Users/rog/Development/RQSheet/RQSheetTests/CharacterWorkspaceChromeTests.swift
git commit -m "feat: add settings destination to extras menu"
```

### Task 2: Build the Settings host screen and importer entry UI

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/SettingsView.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheet/TextImportView.swift`
- Modify: `/Users/rog/Development/RQSheet/RQSheet/CharacterWorkspaceView.swift`
- Test: `/Users/rog/Development/RQSheet/RQSheetTests/CharacterWorkspaceChromeTests.swift`

**Step 1: Write the failing test**

Add source-level expectations for:

- `SettingsView`
- `TextImportView`
- a visible importer action/entry in settings
- `CharacterMoreTabView` rendering `SettingsView`

**Step 2: Run test to verify it fails**

Run the narrow source-level test command for the workspace chrome test.

Expected: fail because settings/importer views do not exist.

**Step 3: Write minimal implementation**

- create a simple `SettingsView` with an importer entry section
- create a `TextImportView` shell with:
  - large text editor
  - `Import` button
  - no parsing logic yet

**Step 4: Run test to verify it passes**

Use the same command and confirm build still succeeds.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/SettingsView.swift /Users/rog/Development/RQSheet/RQSheet/TextImportView.swift /Users/rog/Development/RQSheet/RQSheet/CharacterWorkspaceView.swift /Users/rog/Development/RQSheet/RQSheetTests/CharacterWorkspaceChromeTests.swift
git commit -m "feat: add settings importer entry"
```

### Task 3: Create import domain models for parsed data and review status

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/Import/TextImportModels.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportModelsTests.swift`

**Step 1: Write the failing test**

Write tests for:

- summary row statuses
- parsed section coverage/provenance
- import review rows for character info, attributes, runes, skills, equipment, magic, passions

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=35D3E526-9398-48CC-AB55-F4927A5E103A' -only-testing:RQSheetTests/TextImportModelsTests`

Expected: fail because the import model types do not exist.

**Step 3: Write minimal implementation**

Create types such as:

- `TextImportResult`
- `TextImportReview`
- `TextImportSectionStatus`
- `ParsedCharacterInfo`
- `ParsedSkillEntry`
- `ParsedWeaponEntry`
- `ParsedSpellEntry`

Keep them pure Foundation types.

**Step 4: Run test to verify it passes**

Run the same test target.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/Import/TextImportModels.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportModelsTests.swift
git commit -m "feat: add text import domain models"
```

### Task 4: Implement normalization helpers

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/Import/TextImportNormalizer.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportNormalizerTests.swift`

**Step 1: Write the failing test**

Cover:

- line ending normalization
- stripping `Microbadge: Glorantha fan: ...`
- placeholder detection for `___`, `##`, `--%`
- safe whitespace normalization

**Step 2: Run test to verify it fails**

Run the normalizer test target only.

Expected: fail because the helper does not exist.

**Step 3: Write minimal implementation**

Implement a small normalization utility with no parsing decisions beyond cleanup and placeholder detection.

**Step 4: Run test to verify it passes**

Run the same test command.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/Import/TextImportNormalizer.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportNormalizerTests.swift
git commit -m "feat: add text import normalization"
```

### Task 5: Implement section detection against real examples

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/Import/TextImportSectionDetector.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportSectionDetectorTests.swift`
- Reference: `/Users/rog/Desktop/TXT characters/Ornstal.txt`
- Reference: `/Users/rog/Desktop/TXT characters/Selina.txt`
- Reference: `/Users/rog/Desktop/TXT characters/Beriqet.txt`
- Reference: `/Users/rog/Desktop/TXT characters/Davelia.txt`

**Step 1: Write the failing test**

Write tests that prove the detector can find expected sections in all four example files.

**Step 2: Run test to verify it fails**

Run the detector tests only.

Expected: fail because detection is not implemented.

**Step 3: Write minimal implementation**

Build tolerant section detection using:

- explicit headings
- table signatures
- grouped skill header names
- last-structured-section detection for trailing prose

**Step 4: Run test to verify it passes**

Run the same detector tests.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/Import/TextImportSectionDetector.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportSectionDetectorTests.swift
git commit -m "feat: detect text import sections"
```

### Task 6: Parse character info, attributes, runes, and passions

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/Import/TextImportCoreSectionParser.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportCoreSectionParserTests.swift`

**Step 1: Write the failing test**

Use the example texts to verify parsing of:

- character identity fields
- first cult vs extra cults to `worships`
- all seven attributes
- elemental and paired runes
- passions

**Step 2: Run test to verify it fails**

Run the core parser tests only.

Expected: fail because no core parser exists.

**Step 3: Write minimal implementation**

Implement small per-line parsers and assemble them into the core section parser.

**Step 4: Run test to verify it passes**

Run the same parser tests.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/Import/TextImportCoreSectionParser.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportCoreSectionParserTests.swift
git commit -m "feat: parse identity rune and passion sections"
```

### Task 7: Parse grouped skills with custom skill fallback

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/Import/TextImportSkillsParser.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportSkillsParserTests.swift`
- Reference: `/Users/rog/Development/RQSheet/RQSheet/SkillDefinition.swift`
- Reference: `/Users/rog/Development/RQSheet/RQSheet/CharacterSkill.swift`

**Step 1: Write the failing test**

Cover:

- known group mapping
- known skill mapping
- unknown skill names creating custom skills
- unsupported source groups forcing skills summary red
- placeholders skipped in favor of seeded defaults

**Step 2: Run test to verify it fails**

Run the skills parser tests only.

Expected: fail because the parser does not exist.

**Step 3: Write minimal implementation**

Implement:

- group alias mapping to `SkillGroup`
- seeded skill lookup
- custom skill entry creation for unmatched names
- unsupported-group reporting

**Step 4: Run test to verify it passes**

Run the same tests.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/Import/TextImportSkillsParser.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportSkillsParserTests.swift
git commit -m "feat: parse grouped skills for text import"
```

### Task 8: Parse equipment, weapons, and magic

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/Import/TextImportInventoryAndMagicParser.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportInventoryAndMagicParserTests.swift`
- Reference: `/Users/rog/Development/RQSheet/RQSheet/Weapon.swift`
- Reference: `/Users/rog/Development/RQSheet/RQSheet/CharacterSpell.swift`

**Step 1: Write the failing test**

Cover:

- equipment lines
- weapon rows
- armor text captured under equipment
- rune spells
- spirit magic spells
- current MP defaulting to max when missing

**Step 2: Run test to verify it fails**

Run the inventory/magic parser tests.

Expected: fail because parser is missing.

**Step 3: Write minimal implementation**

Implement tolerant row parsers for:

- weapons table rows
- spell rows with `(points)`
- plain equipment lines

Do not import calculated combat values.

**Step 4: Run test to verify it passes**

Run the same tests.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/Import/TextImportInventoryAndMagicParser.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportInventoryAndMagicParserTests.swift
git commit -m "feat: parse equipment weapons and magic sections"
```

### Task 9: Assemble the full parser and trailing-prose capture

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/Import/TextImportParser.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportParserIntegrationTests.swift`

**Step 1: Write the failing test**

Add integration tests for full-file parsing of Ornstal, Selina, Beriqet, and Davelia.

Specifically verify:

- trailing prose after the final structured section goes to notes
- prose in the middle of structured data does not
- summary row statuses are computed correctly

**Step 2: Run test to verify it fails**

Run the integration parser tests only.

Expected: fail because the full parser orchestration is not implemented.

**Step 3: Write minimal implementation**

Wire together:

- normalizer
- section detector
- core parser
- skills parser
- equipment/magic parser
- status/report builder

**Step 4: Run test to verify it passes**

Run the same integration tests.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/Import/TextImportParser.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportParserIntegrationTests.swift
git commit -m "feat: assemble text importer parser"
```

### Task 10: Add the review screen and save-time name prompt

**Files:**
- Modify: `/Users/rog/Development/RQSheet/RQSheet/TextImportView.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheet/TextImportReviewView.swift`
- Create: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportReviewViewTests.swift`

**Step 1: Write the failing test**

Cover:

- paste -> import -> review navigation
- display of all summary rows
- save-time name prompt when a candidate name exists
- cancel path creating no character

**Step 2: Run test to verify it fails**

Run the review view tests.

Expected: fail because the review flow is not implemented.

**Step 3: Write minimal implementation**

- run parsing only when `Import` is tapped
- show a review screen from the parsed result
- present a name prompt immediately before persistence when a parsed name exists

**Step 4: Run test to verify it passes**

Run the same tests.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/TextImportView.swift /Users/rog/Development/RQSheet/RQSheet/TextImportReviewView.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportReviewViewTests.swift
git commit -m "feat: add text import review flow"
```

### Task 11: Persist imported data as a new character and switch workspace

**Files:**
- Create: `/Users/rog/Development/RQSheet/RQSheet/Import/TextImportApplier.swift`
- Modify: `/Users/rog/Development/RQSheet/RQSheet/TextImportView.swift`
- Modify: `/Users/rog/Development/RQSheet/RQSheet/ContentView.swift`
- Test: `/Users/rog/Development/RQSheet/RQSheetTests/TextImportParserIntegrationTests.swift`
- Test: `/Users/rog/Development/RQSheet/RQSheetTests/CharacterWorkspaceShellTests.swift`

**Step 1: Write the failing test**

Cover:

- save always creates a new character
- current workspace switches to the imported character
- extra cults land in `worships`
- current MP defaults to max when missing

**Step 2: Run test to verify it fails**

Run the relevant integration tests.

Expected: fail because no persistence applier exists.

**Step 3: Write minimal implementation**

- seed a new character
- apply imported values section by section
- create custom skills when needed
- create passions, weapons, equipment items, and spells
- route the app to the new character after save

**Step 4: Run test to verify it passes**

Run the same tests.

**Step 5: Commit**

```bash
git add /Users/rog/Development/RQSheet/RQSheet/Import/TextImportApplier.swift /Users/rog/Development/RQSheet/RQSheet/TextImportView.swift /Users/rog/Development/RQSheet/RQSheet/ContentView.swift /Users/rog/Development/RQSheet/RQSheetTests/TextImportParserIntegrationTests.swift /Users/rog/Development/RQSheet/RQSheetTests/CharacterWorkspaceShellTests.swift
git commit -m "feat: save imported text as new character"
```

### Task 12: Final verification and cleanup

**Files:**
- Modify: any touched importer files as needed
- Test: all relevant importer, workspace, and model tests

**Step 1: Run focused importer tests**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=35D3E526-9398-48CC-AB55-F4927A5E103A' -only-testing:RQSheetTests/TextImportModelsTests -only-testing:RQSheetTests/TextImportNormalizerTests -only-testing:RQSheetTests/TextImportSectionDetectorTests -only-testing:RQSheetTests/TextImportCoreSectionParserTests -only-testing:RQSheetTests/TextImportSkillsParserTests -only-testing:RQSheetTests/TextImportInventoryAndMagicParserTests -only-testing:RQSheetTests/TextImportParserIntegrationTests -only-testing:RQSheetTests/TextImportReviewViewTests
```

Expected: all pass. If the simulator harness stalls, capture that explicitly and run `xcodebuild build` as a secondary verification, but do not claim tests passed without actual evidence.

**Step 2: Run workspace regression tests**

Run:

```bash
xcodebuild test -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=35D3E526-9398-48CC-AB55-F4927A5E103A' -only-testing:RQSheetTests/CharacterWorkspaceChromeTests -only-testing:RQSheetTests/CharacterWorkspaceShellTests -only-testing:RQSheetTests/CharacterListViewTests
```

Expected: pass.

**Step 3: Run a full build**

Run:

```bash
xcodebuild build -project /Users/rog/Development/RQSheet/RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,id=35D3E526-9398-48CC-AB55-F4927A5E103A'
```

Expected: `** BUILD SUCCEEDED **`

**Step 4: Commit final cleanup**

```bash
git add /Users/rog/Development/RQSheet
git commit -m "test: finalize text importer coverage"
```
