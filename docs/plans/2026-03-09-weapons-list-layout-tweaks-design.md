# Weapons List Layout Tweaks Design

**Date:** 2026-03-09

## Goal

Refine the redesigned weapons list so each compact row uses horizontal space more efficiently, the disclosure affordance matches the requested down-triangle style, and expanding or collapsing a weapon feels like the row grows in place instead of causing the surrounding list to jump.

## Current Context

The weapons list already uses a translucent `List` with one expandable `WeaponRowCard` per weapon. The current compact row still gives fixed-width space to `%`, experience, `SR`, damage, and the disclosure button, which leaves the name column tighter than desired. Expansion currently uses an insertion/removal transition on the detail block, which makes nearby rows jump during slow-motion inspection.

## Chosen Approach

Keep the existing `List` implementation and adjust only the row geometry and animation behavior inside `CombatView`.

This keeps native swipe-to-delete, existing edit-sheet presentation, and the rest of the redesign intact. The row will become slightly wider by reducing list row insets, then reclaim more width for the name by shrinking the fixed widths and gaps for `%`, experience, `SR`, and the disclosure control. The disclosure icon will stay down-pointing in both states, using an outlined appearance while collapsed and a filled appearance while expanded.

For animation, the expanded content should no longer be inserted with a move transition. Instead, the row should animate its internal height and opacity while staying structurally present, so the list scrolls around the growing card rather than visibly snapping rows out of the way.

## Alternatives Considered

### 1. Keep `List` and tune row layout and animation

Recommended. Smallest code change, preserves all current list behavior, and directly targets the spacing and expansion issues.

### 2. Keep `List` but build a measured custom height animator

Provides tighter control, but adds complexity and state management that is not justified for this tweak.

### 3. Replace `List` with `ScrollView` and `LazyVStack`

Would improve animation control, but risks regressing swipe actions and the current native list behavior. Not worth the tradeoff for this pass.

## Testing Strategy

Add focused source-level tests around:

- reduced row inset constants
- tighter compact-row width allocation
- down-triangle disclosure icon styling
- removal of the insert/remove transition that currently causes the jump

Then rerun the existing combat and equipment regression slice to confirm no behavior drift.
