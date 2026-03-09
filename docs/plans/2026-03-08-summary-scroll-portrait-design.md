# Summary Scroll Portrait Design

## Goal

Refactor the Summary screen so the portrait and biography fields start as a large hero block at the top of the screen, then smoothly collapse into the compact identity layout as the user scrolls upward.

## User Experience

On initial load, the Summary screen should show:

- A full-width portrait container at the top of the content.
- The portrait container should be a rounded square using the same corner radius language as the rest of the Summary UI.
- The camera badge remains visible at the portrait's top-right corner in all states.
- `Family`, `Patron`, and `Date of Birth` appear underneath the portrait.

As the user scrolls upward:

- The portrait shrinks from the full-width square into the smaller leading portrait used in the current Summary identity area.
- `Family`, `Patron`, and `Date of Birth` animate upward into the compact metadata position that sits beside the portrait in the current design.
- Once the collapse finishes, continued scrolling should move the section off screen naturally with the rest of the content.

As the user scrolls downward:

- The compact state should expand back into the full-width hero state.
- The transition should be continuous and reversible, not a snapped state change.

## Architecture

The existing `identityCard` in `StatsOverviewView` is too static for this effect because it renders the portrait and metadata in a single `SummaryCard` with fixed layout. The refactor should replace that card with a dedicated, scroll-reactive profile section that lives at the top of the Summary content stack.

The scroll transition should be driven by a single clamped progress value derived from vertical scroll offset:

- `0`: fully expanded hero layout
- `1`: fully collapsed compact layout

That progress value should control:

- portrait width and height
- portrait corner radius
- metadata container position
- section spacing and top offsets

This keeps the motion deterministic and easy to tune without splitting the animation across unrelated state.

## Layout Strategy

The Summary scroll view should report its vertical position using a small `PreferenceKey`-based helper. `StatsOverviewView` can then compute collapse progress near the top of the scroll range.

The new profile section should:

- render above the other Summary cards
- maintain the existing card visual treatment for the compact destination
- preserve `PhotosPicker` behavior and accessibility label
- keep the camera badge visually attached to the portrait in both states

The rest of the Summary cards should remain unchanged below this section.

## Component Changes

### `StatsOverviewView`

- Remove the old fixed `identityCard`.
- Add scroll offset tracking to the Summary scroll view.
- Add a dedicated profile section view that receives the current character, `SummaryViewModel`, and collapse progress.

### `SummaryPortraitView`

- Generalize sizing and shape so it can support both:
  - expanded rounded-square hero presentation
  - collapsed compact portrait presentation

This is the cleanest place to keep portrait rendering logic while allowing the parent layout to control dimensions.

### Tests

`StatsOverviewViewTests` should be extended to verify the source contains:

- scroll offset preference plumbing
- a dedicated profile section replacing the fixed `identityCard`
- state derived from scroll progress for portrait collapse

These tests should remain source-level, matching the existing test strategy in this codebase.

## Risks

- SwiftUI scroll offset reporting can be noisy; the implementation should clamp and normalize values before using them.
- Geometry-driven layout can jitter if multiple nested readers fight each other; keep the offset measurement narrow and local to the scroll view.
- Over-animating text layout can look unstable; prefer explicit offsets/frames driven by progress rather than implicit layout changes alone.

## Out of Scope

- Changing edit flows or portrait picking behavior
- Reworking the rest of the Summary cards
- Adding new stored model data
