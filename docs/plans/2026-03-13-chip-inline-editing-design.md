# Chip Inline Editing Design

**Date:** 2026-03-13

## Goal

Bring the in-place editable chip behavior from the existing money chip pattern into the gameplay screens that still use plain text values:

- rune affinity chips in `RunesView`
- the combat HP chip in `CombatView`
- the MP and RP chips in `MagicView`

The new behavior must include:

- inline editing inside the chip
- a green animated completion button
- a visible editable marker
- keyboard-aware scrolling so the active chip is not hidden while editing

## Constraints

- The rune chips edit a single numeric value.
- Combat HP uses a split display like `4/5`; only the left/current value is editable.
- Magic points uses a split display like `4 / 5`; only the left/current value is editable.
- Rune points remains a single editable value.
- Existing chip sizing should remain visually stable while editing; the chip should not visibly jump or reflow.
- Existing per-screen chrome and layout should stay intact; only chip editing behavior should be upgraded.

## Recommended Approach

Extract a small shared inline chip value editor instead of copying behavior screen-by-screen.

This shared control should own:

- editable marker display
- editing text field state
- green animated completion button
- value formatting for:
  - single editable value
  - editable current value plus read-only max value

Each screen keeps ownership of:

- which chip is currently editing
- how the chip is laid out
- how the edited value maps back onto the model

This keeps the UI consistent without forcing the screens into one oversized reusable chip container.

## Component Shape

Add a shared view, tentatively `EditableChipValue`, with two modes:

- `singleValue`
  - used by rune affinity percentages
  - shows only the editable number
- `currentOfMax`
  - used by combat HP and magic MP
  - shows editable current value and read-only suffix for max

The component also accepts:

- whether it is currently editing
- callbacks for begin/end editing
- a binding for the editable integer value
- optional accessibility identifiers/labels

The completion affordance should animate between idle and editing states rather than popping in abruptly, matching the existing money chip feel.

## Screen Integration

### Runes

`RunicAffinityNodeView` should switch its existing percentage slot over to the shared editor.

- editing remains per-rune chip
- the experience check control stays as-is
- the editable marker should sit with the value region, not replace the rune icon or label

### Combat

`HitPointsCombatChip` should move from a raw `TextField` to the shared split-value editor.

- only `currentHitpoints` is editable
- `maxHitpoints` remains read-only
- the chip still reads as HP, not as a generic editor

### Magic

`MagicPointsEditor` becomes a split-value integration of the shared editor.
`RunePointsEditor` becomes a single-value integration of the shared editor.

This keeps MP and RP visually related while respecting the fact that only MP has the `/max` suffix.

## Keyboard Avoidance

Do not rely on extra bottom padding alone.

Each of the three screens should live inside a scrollable container that can scroll the active editor into view when editing starts. The screen-level state should track the active editing chip id, and the scroll view should bring that chip toward a safe visible anchor above the keyboard.

This should be implemented per screen using the same pattern, not by trying to make the chip component itself own scrolling.

## Testing

Add source-level regression coverage first, then implement:

- `RunesView` uses the shared editable chip value
- `CombatView` HP chip preserves a read-only max suffix while editing only the current value
- `MagicView` MP and RP use the shared editable chip value modes
- the editable marker and completion button exist in the shared component
- any layout metrics needed to keep chip dimensions stable stay explicitly tested

## Risks

- Keyboard avoidance can become brittle if attached to the wrong view layer.
- If edit state is modeled separately in each screen without a small shared pattern, the behavior will drift quickly.
- Split-value chips need to keep formatting and clamping logic separate from display logic, or they will be hard to reuse cleanly.

## Follow-up Adjustments

After the first implementation pass, the desired behavior is narrower and more specific:

- Rune chips should always be individually editable.
- The workspace-level rune edit button should be removed entirely.
- The editable marker should move into the chip header row near the rune title instead of overlaying the value area.
- The `%` suffix for rune chips should not render while the value field is actively editing.
- The combat HP chip must reserve enough width for both the full `current/max` display and the editing affordance so it does not shrink in display mode or grow in edit mode.
- The magic MP and RP chips should reserve enough display width for their idle text, with MP sized for the `/max` suffix and RP sized for the single value.
- If enlarging the rune value region affects pentagram layout, the elemental rune nodes should move outward by increasing the pentagram radius slightly rather than letting chip chrome collide.
- Magic chip scrolling should stop below the fixed search bar rather than aligning the edited row to the very top of the list.

These are refinements to the shared-editor approach, not a new architecture. The shared component remains the right base, but it needs more explicit layout slots so marker, value, suffix, and completion button do not compete for the same space.

## Animation Follow-up

The completion affordance should now feel like part of the chip transition rather than a static control that appears once editing starts.

- When editing begins, the numeric content should animate left to make space for the completion button.
- The completion button should appear with its center fixed in the final resting position.
- The button animation should start at `25%` opacity and `25%` scale, spring past the final size to roughly `110%`, then settle back to `100%`.
- The text field should not jump; it should animate into its editing position as the button arrives.
- When the green completion button is tapped, the keyboard should dismiss, the button should animate away, and the display text with suffix should animate back into its idle position.

This behavior should be owned by `EditableChipValue` so all chip integrations stay visually consistent.

## Scroll Behavior Follow-up

The green completion button should finish editing locally without causing a second parent scroll jump.

The parent screens should still scroll when editing begins, but they should not treat completion-button dismissal as a new “active editor selected” event. In practice this means the shared chip component needs a distinct completion path that ends editing without re-triggering the parent screen’s scroll-to-anchor behavior.
