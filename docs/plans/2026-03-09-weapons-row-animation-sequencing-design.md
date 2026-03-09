# Weapons Row Animation Sequencing Design

**Date:** 2026-03-09

## Goal

Fix the weapon row expansion so it reads as one card growing in place: the disclosure triangle fills immediately, the card expands and pushes later rows down, and the detail content fades in only after there is room for it inside the clipped card bounds.

## Current Context

The current `WeaponRowCard` keeps the expanded detail block structurally attached, but the whole card is driven by a single animation on `isExpanded`. In practice this still looks wrong: the expanded card appears to jump, the size change and detail visibility are coupled too tightly, and the detail content feels like it is being added back after layout settles.

## Chosen Approach

Keep a single card instance and split the animation into two coordinated parts:

1. Animate a measured detail container height from `0` to its full intrinsic height while clipping the container.
2. Animate detail opacity separately, with a short delay on expand so the card mostly reaches its final size before the detail content becomes visible.

This preserves the existing `List`, swipe actions, and row structure. The key change is moving away from one blanket animation on the full card and instead using explicit state for detail height and detail opacity.

## Alternatives Considered

### 1. Measured clipped height plus delayed fade

Recommended. Best match for the requested interaction and still a contained change inside `WeaponRowCard`.

### 2. Animate height and opacity together from the start

Simpler, but still risks the content appearing too early and contributing to the visual jump.

### 3. Morph between separate compact and expanded card trees

Could look polished, but introduces more moving parts and increases the risk of a second-card illusion inside `List`.

## Testing Strategy

Add focused source-level assertions for:

- explicit detail height state
- separate detail opacity state
- a clipped detail frame driven by measured height
- explicit change handling for `isExpanded`
- removal of the old whole-card animation binding

Then rerun the existing combat and equipment regression slice.
