# iPad character tiles

Status: approved by Rog on 8 October 2026.

The iPad character workspace will show Summary, Runes, Combat, Magic, Skills, Knowledge, Equipment, and Notes together on one vertically scrolling page. Each tile will show its full content and grow with it. Tiles, their lists, and the Notes editor will not scroll independently. The iPhone will retain its existing views and navigation, including the Summary portrait animation, top rune affinities, and skill bonuses.

## Layout

Portrait will use two equal-width columns, with these rows:

| Left | Right |
| --- | --- |
| Summary | Runes |
| Combat | Magic |
| Skills | Knowledge |
| Equipment | Notes |

Landscape will use three equal-width columns, with these rows:

| Left | Centre | Right |
| --- | --- | --- |
| Summary | Runes | Magic |
| Combat | Skills | Knowledge |
| Equipment | Notes | |

Tiles will align at the top of each row. A new row will start below the tallest tile in the preceding row. Tile content will determine height; the layout will not truncate lists or impose fixed tile heights. The final landscape cell will remain empty. Tile backgrounds, rounded borders, rune motifs, and row controls will follow the existing visual style. The page will use the available window width instead of the previous 900-point content limit.

Rog approved the additional narrow-window behaviour during implementation: an iPad window narrower than 680 points will use the existing iPhone tabbed layout. Other windows will use the portrait or landscape tile arrangement based on window shape. Both hosts will retain stable identities so unfinished edits and searches survive switching between compact and tiled layouts. Opening the keyboard will not change that arrangement. Rotation and resizing will preserve editor and search state.

## Tile content and skills

Summary will show a compact static portrait, profile details, characteristics, derived stats, Honor, and passions. It will omit top rune affinities and skill bonuses. Portrait changes, POW experience checks, and adding passions will remain available.

Skills will contain Agility, Communication, Manipulation, Magic, Perception, and Stealth, in their existing order. Knowledge will contain the whole Knowledge group. Group bonuses, percentage values, experience checks, adding, editing, and deleting skills will remain available. Each tile will have its own search field scoped to its groups. The split will be fixed across characters so groups remain easy to find.

The approved read-only inspection of the iPhone database found these counts on 8 October 2026:

| Character | Skills tile | Knowledge tile |
| --- | ---: | ---: |
| Ornstal | 47 | 39 |
| Voraneva Slip-Wake | 45 | 47 |

Keeping contiguous groups in their current order would leave an uneven split. A dynamic split could balance every character but would move groups between tiles. The fixed Knowledge split keeps groups intact and fits both saved characters.

Combat will retain the hit-location diagram, HP and damage controls, weapons, expansion, equipped state, experience checks, and weapon editors. Runes will retain elemental and paired affinity editing. Magic will retain points, spell sections, common rune spells, searching, and editors. Equipment will retain encumbrance, searching, equipped state, and editors. Lists will use content stacks in tiles; delete actions will be exposed through accessible row menus where native List swipe actions no longer apply.

Notes will remain editable in place and expand to fit its text, with a minimum height for an empty note. The outer page will scroll to keep the insertion point and inline number editors visible above the keyboard.

The toolbar will show the character name, character editing, and Settings/import. Settings will open separately from the tile page. Closing and reopening Settings during the same character session will preserve unfinished import text. Returning to the character list and opening another character will create that character's workspace state.

## Implementation boundaries and verification

CharacterWorkspaceView will select the existing phone shell or the new iPad tile page. Each section will expose reusable content separately from its phone scrolling container. Existing models, editor sheets, data bindings, importing, and persistence will continue to own their current behaviour; this rewrite will not change the data schema or skill calculations. The tile layout will own ordering, available widths, and the outer scroll view. Section views will own their search and editor state. Stable tile identities will preserve those states when layout changes.

Behaviour tests will cover both row orders, the narrow-window phone fallback, group membership without loss or duplication, and Summary content differences. iPad UI tests will cover portrait and landscape, page scrolling from tile content, complete long lists, growing Notes, keyboard visibility, editing, checks, deletion, rotation state preservation, and Settings import drafts. iPhone regression tests will cover its tabs and More destinations, Summary content, and portrait scrolling behaviour. Simulator screenshots will be inspected in both orientations using populated characters. Only character names and skill-group counts from the temporary phone copy will be used for design evidence; private database files will remain outside the repository.

The isolated worktree is `/Users/rog/.codex/worktrees/ipad-tiles/RQiOS`, based on `codex/ipad-workspace` at `b952672`. The existing CharacterWorkspaceChromeTests and WorkspaceLayoutTests passed before changes: seven Swift Testing tests in two suites. No application code has changed yet.
