# iPad Column and Character Card Redesign

## Goal

Reduce unused space on the iPad character worksheet, keep all section content in one vertical scroll, balance the two skills tiles for each character, and make the character picker easier to scan.

## Approved behavior

### Worksheet columns

- Keep the existing compact-width behavior: below 680 points, show the iPhone tabbed workspace.
- On iPad widths, show two vertical columns in portrait and three in landscape.
- Preserve the current reading sequence for each orientation by flattening the existing row order, then splitting that sequence into contiguous top-to-bottom columns.
- Choose column boundaries from measured tile heights to minimize the difference between the tallest and shortest columns while preserving order. Each tile appears once and stays in its existing relative sequence.
- Keep one outer vertical `ScrollView`. Tiles and their content do not scroll independently.
- Continue to scroll the outer view to an editor when an on-screen keyboard appears.
- The Summary tile omits top rune affinities and skill bonuses. The iPhone Summary keeps both. The iPad Summary portrait does not animate in response to outer scrolling.

The flattened order is Summary, Runes, Combat, Magic, Skills 1, Skills 2, Equipment, Notes in portrait, and Summary, Runes, Magic, Combat, Skills 1, Skills 2, Equipment, Notes in landscape. With the current eight tiles, portrait columns will typically split near four tiles each and landscape columns near three, three, and two; measured heights determine the exact contiguous boundaries.

### Dynamic skill tiles

- Split the seven `SkillGroup` areas into two contiguous, non-overlapping groups. Preserve `SkillGroup.allCases` order, and include each area in exactly one tile.
- Choose the boundary from the current character's saved skills, using the skill count per area and the per-area heading/add-control overhead to estimate each tile's height. Select the boundary that makes the two estimated heights closest; resolve ties by preferring the earlier boundary.
- Recompute when the character's saved skill collection changes so adding or deleting skills can move an entire area between tiles.
- Label the tiles “Skills 1” and “Skills 2”. Keep each area's skills together, with its existing search, bonus, add, edit, experience-check, and delete interactions.

### Character picker cards

- Use an adaptive grid: two cards per row at regular iPad widths, and one card per row on iPhone or in windows narrower than 680 points.
- Each card shows the character portrait at left, with name, family, and primary god beside it. Omit empty family or god values.
- Treat the first worship/cult entry as the primary god, consistent with the importer’s ordering.
- Show the four top rune icons in the card without percentages.
- Tapping a card opens that character's existing detail workspace destination.
- Preserve character creation and destructive deletion, with deletion confirmation. Card actions replace the list's swipe action where needed for grid compatibility.

## Implementation shape

- Replace the row-based tile arrangement with an order-preserving column layout that measures tile heights at the proposed column width and assigns contiguous ranges to columns.
- Use a pure partitioning helper for column boundaries and skill-group boundaries so the decisions can be tested without rendering the full app.
- Keep selection and adaptive sizing in the current navigation flow; do not introduce another navigation stack for the grid.
- Reuse the current portrait and rune presentation components where possible.

## Verification

- Unit tests cover portrait and landscape tile order, contiguous/no-duplicate column assignment, balanced boundaries for uneven tile heights, dynamic skill-group boundaries for both known character distributions and empty/small collections, and stable tie handling.
- UI tests cover character-card selection opening details, displayed metadata and four runes, delete confirmation, two-column regular-width iPad layout, one-column compact layout, and the one-scroll worksheet at portrait and landscape widths.
- Build the app and relevant test targets. Run focused unit/UI tests where the available simulator supports them; report any simulator limitation separately from build results.

## Out of scope

- Changing iPhone's tabbed navigation or its Summary content.
- Changing skill grouping definitions, bonus calculations, rune ranking, import semantics, or sync behavior.
- Introducing independently scrolling tile content.
