# Combat Header And Weapon Layout Design

**Date:** March 9, 2026

**Branch:** `codex/weapons-list-redesign`

**Context**

The weapons list now uses a `ScrollView`/`LazyVStack` structure so the expand animation behaves correctly. The next pass refines the combat header and the weapon row layout without reverting to `List`.

## Goals

- Replace the current centered `Total Hitpoints` label with a combat header row that matches the rest of the app better.
- Make `current HP` editable inline inside a left-aligned chip.
- Add a right-aligned `Damage Bonus` chip derived from `STR + SIZ`.
- Reduce the harsh visual cutoff where weapons scroll under the combat header by using a gradient handoff instead of a hard edge.
- Fix compact weapon row alignment for longer strike-rank strings such as `2/8`.
- Make the expanded weapon details larger and positionally stable regardless of which optional values are present.

## Approved Direction

### 1. Combat Header Row

Replace the single `Text("Total Hitpoints: ...")` line with two translucent chips in one horizontal row above the weapons scroller.

- Left chip: `HP`
- Right chip: `Damage Bonus`
- Both chips stay visually consistent with the app's existing translucent card language.
- The header remains outside the weapon scroller so it stays stable while the list scrolls beneath it.

### 2. Inline HP Editing

The left `HP` chip contains:

- label: `HP`
- editable integer field for current HP
- static `/maxHP` suffix

Behavior:

- editing is inline inside the chip, not via sheet or popup
- only integer input is accepted
- parsed values write directly to `character.currentHitpoints`
- model clamping remains authoritative, so values stay within `1...maxHitpoints`
- the text field reflects the clamped model value after edits

### 3. Damage Bonus

Add a derived display for damage bonus based on `STR + SIZ`.

Rule:

- `<= 12`: `-1D4`
- `13...24`: `-`
- `25...32`: `+1D4`
- `33...40`: `+1D6`
- `41...56`: `+2D6`
- above `56`: add `+1D6` for each additional `16` points beyond `56`

This should live as a model or view-model helper rather than being hardcoded in the view body.

### 4. Scroll/Header Handoff

The top of the weapon scroller should fade under the combat header rather than disappear abruptly.

Approved direction:

- keep the header row visually above the scroller
- add a top gradient mask or overlay treatment so the scrolling cards soften into the header area
- preserve translucency so the rune background still shows through

### 5. Compact Weapon Row Alignment

The compact row keeps the current columns:

- name
- `%`
- experience check
- `SR`
- damage
- disclosure

Changes:

- make the `SR` area a fixed-width column large enough for longer values such as `SR 2/8`
- keep the experience checkbox column fixed so checkboxes stay vertically aligned across rows
- reduce wasted gap between `SR` and damage

### 6. Expanded Weapon Details

The expanded section keeps the current label/data format but moves from free-flowing chips to fixed slot positions.

Layout:

- larger text than the current `footnote`-sized detail presentation
- row 1: `HP`, `ENC`, `Type`, `Equipped`
- row 2: fixed slots, with `Range` occupying the last slot only when present
- if `Range` is absent, hide both label and value and collapse the second row entirely

This keeps positions stable for the values that remain visible while avoiding orphaned labels.

## Testing Direction

- Add model/view-model coverage for damage bonus calculation.
- Update `CombatView` source-level tests to require the new header chips, gradient handoff, fixed-width SR column, and fixed expanded-detail slot layout.
- Verify the existing focused combat regression slice and the broader weapons/equipment/summary regression slice.

