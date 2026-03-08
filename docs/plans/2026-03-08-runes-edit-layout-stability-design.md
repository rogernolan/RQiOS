# Rune Edit Layout Stability Design

## Goal

Remove the visible layout drift that occurs when the Runes screen toggles between read-only and editing while preserving the current edit animation.

## Problems To Fix

- chip titles shift slightly to the right in editing mode
- experience checkboxes shift slightly to the right in editing mode
- rune chips in the elemental ring shift slightly downward in editing mode
- rune chips become slightly larger in editing mode
- the inline percentage editor sits against the chip edge in editing mode

## Chosen Approach

Keep the existing edit toggle and animation timing, but make each rune chip render against fixed layout metrics that do not depend on editing state.

This means:

- the chip keeps the same outer width, padding, background, and border in both modes
- the title row keeps a fixed checkbox slot so text and checkbox alignment do not drift
- the percentage area keeps a fixed-width container in both modes
- read-only mode renders text inside that shared container
- editing mode renders the text field inside the same shared container with explicit inset
- the edit-only spacer above the elemental affinities section is removed so the ring stays anchored

## Component Changes

### Shared Chip Metrics

Introduce a small shared metrics type for the rune chip layout. This gives the view a single source of truth for:

- chip width and padding
- title-row spacing
- checkbox frame size
- icon size
- percentage slot width
- percentage editor size and inset

The main reason to extract these values is testability. The rendering bug comes from edit mode using a different intrinsic layout; a shared metrics type lets tests assert the invariants directly.

### Rune Chip Rendering

`RunicAffinityNodeView` will keep the same overall structure but stop using edit-mode-specific outer geometry.

Implementation details:

- reserve a fixed frame for the checkbox button image
- keep the title text aligned to the same leading edge in both states
- keep the percentage content in a fixed slot aligned trailing
- apply a small inset around the editing field so it no longer touches the chip border

### Elemental Ring Positioning

Remove the extra top spacer inside `RunicAffinitiesPentagramView`. The ring should not move vertically when editing begins.

## Testing Strategy

Add unit tests for the new layout metrics helper to lock the intended invariants:

- display and edit percentage slot widths are identical
- checkbox slot width is fixed and non-zero
- editor inset leaves space between the field and the chip edge

This does not snapshot the SwiftUI hierarchy, but it gives us a stable regression check around the layout rules that caused the drift.

## Non-Goals

- redesigning the rune chips
- changing the edit button behavior
- changing data flow for rune percentages or experience checks
- adding new animations
