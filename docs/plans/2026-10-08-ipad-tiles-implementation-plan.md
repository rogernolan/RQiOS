# iPad character tiles implementation plan

> For agentic workers: use superpowers:subagent-driven-development for the section adaptation, then integrate and verify the tile page in this session.

**Goal:** Replace iPad section navigation with the approved single scrolling character tile page.

**Architecture:** A CharacterSectionPresentation environment value selects the existing page containers or intrinsic tile content. The iPad page uses a custom SwiftUI Layout with stable tile identities, so changing column count does not recreate section state. CharacterWorkspaceView owns the page and retained Settings/import presentation.

**Tech stack:** SwiftUI, SwiftData, UIKit for a growing text editor, Swift Testing, XCTest, iOS 26.2 minimum.

## Constraints

Use the portrait and landscape row orders in the approved design. Use the iPhone tabbed layout below 680 points, as Rog approved during implementation. Tiles must contain no scrolling lists or editors. Keep iPhone behaviour and the persistence schema. The skill split is six groups in Skills and Knowledge alone. Retain searches, editing, deletion, checks, equipped controls, and import drafts. Keep Notes editable with natural height and keyboard visibility. Preserve section state across rotation.

## Task 1: Section content

Files: create RQSheet/CharacterSectionPresentation.swift; modify StatsOverviewView.swift, SkillsView.swift, CombatView.swift, RunesView.swift, MagicView.swift, EquipmentView.swift, NotesView.swift; create RQSheet/GrowingNotesEditor.swift.

- [ ] Run the new tile-page UI test before implementation and observe missing tile controls.
- [ ] Add environment presentation `.page` (default) and `.tile(width: CGFloat)`, with `isTile` and optional `tileWidth`. Add `sectionRuneBackground(runeName:fixedRotation:)` that uses the existing background only for pages.
- [ ] Add `SkillsView(character:groups:)`, defaulting groups to SkillGroup.allCases. Tile mode uses VStack rows, scoped search, and accessible deletion menus. Keep phone List and sheet behaviour.
- [ ] Expose intrinsic tile branches for all remaining sections, reusing current content and sheet handlers. Combat removes both scroll wrappers in tile mode. Summary uses a static compact profile and excludes top runes and skill bonuses. Notes uses a non-scrolling growing UITextView bound to character.notes, with keyboard-safe caret visibility.
- [ ] Build with the generic iOS Simulator destination and report the command/output. Self-review the iPhone branches and report any limitations.

Interface consumed by the tile page:

```swift
.environment(\.characterSectionPresentation, .tile(width: tileWidth))
SkillsView(character: character, groups: [.agility, .communication, .manipulation, .magic, .perception, .stealth])
SkillsView(character: character, groups: [.knowledge])
```

## Task 2: Page layout and retained settings

Files: create RQSheet/IPadCharacterTilesView.swift and RQSheet/IPadTileLayout.swift; modify CharacterWorkspaceView.swift; create RQSheetTests/IPadTileLayoutTests.swift; modify RQSheetUITests/WorkspaceNavigationUITests.swift.

- [ ] Add behaviour tests for portrait rows, landscape rows, narrow phone fallback, and complete skill partition.
- [ ] Implement IPadCharacterTile enum with stable canonical order; IPadTileArrangement computes rows, phone fallback, and column count. IPadTileLayout measures each tile at equal width and starts rows below their tallest tile.
- [ ] Use one ForEach over canonical tile order inside the custom Layout, so rotation changes placement without reparenting sections. Render titled rune tiles and one outer ScrollViewReader/ScrollView, including editor anchors and a keyboard-safe Notes editor.
- [ ] Replace the iPad hidden TabView with the tile page. Retain both the compact phone and tile hosts across width changes; hide the inactive host from interaction and accessibility. Keep phone navigation. Add retained Settings overlay and toolbar close control; the settings view stays mounted across dismissal so import drafts survive. Character edit remains in the toolbar.
- [ ] Run unit layout tests and iPad navigation/editing UI tests. Inspect screenshots with populated fixture characters in both orientations.

Expected orders:

```swift
portrait = [[.summary, .runes], [.combat, .magic], [.skills, .knowledge], [.equipment, .notes]]
landscape = [[.summary, .runes, .magic], [.combat, .skills, .knowledge], [.equipment, .notes]]
```

## Task 3: Behaviour verification and review

- [ ] Run focused existing view-model/editor tests, tile unit tests, iPad UI tests, and iPhone navigation/Summary regressions.
- [ ] Cover long skill/spell/equipment lists, note growth, page scrolling when swiping tile content, editing and deletion, experience checks, rotation search/editor state, and settings import draft retention.
- [ ] Generate a complete diff package and request an independent spec and quality review. Resolve material findings and re-run covering checks.
- [ ] Record actual verification results and limits in this plan. Commit reviewed work in the managed worktree; keep device database copies outside the repository.

Commands (use per-run result paths and disable parallel simulator testing):

```sh
rtk proxy xcodebuild build -project RQSheet.xcodeproj -scheme RQSheet -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/rq-ipad-tiles-baseline CODE_SIGNING_ALLOWED=NO
rtk proxy xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=27.0' -derivedDataPath /private/tmp/rq-ipad-tiles-baseline -parallel-testing-enabled NO -only-testing:RQSheetUITests/WorkspaceNavigationUITests CODE_SIGNING_ALLOWED=NO
rtk proxy xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' -derivedDataPath /private/tmp/rq-ipad-tiles-baseline -parallel-testing-enabled NO -only-testing:RQSheetUITests/WorkspaceNavigationUITests -only-testing:RQSheetUITests/RQSheetUITests/testSummaryCharacteristicsRemainVisibleAfterScrollCycle CODE_SIGNING_ALLOWED=NO
```
