# Combat Weapon Swipe Gap Design

## Goal

Adjust the Combat weapons swipe-to-delete motion so the revealed resting state leaves a visible gap between the row and the delete pill, and so pill translation only happens during overdrag.

## Current Problem

The current swipe row reveals the delete pill by moving the row to a resting position that aligns too tightly with the pill. The user wants a more Apple-like motion where:

- the row rests with a fixed gap to the pill
- the pill grows and fades in during reveal, but does not translate yet
- only overdrag moves the pill
- pill overdrag is capped independently from row overdrag

## Approved Behavior

### Revealed Resting State

- The row springs to a revealed resting offset that leaves a `15pt` gap between the row card trailing edge and the delete pill leading edge.
- The delete pill remains at its resting position in that state.

### Reveal Animation

- During the initial part of the swipe, the row follows the finger.
- During that same phase, the delete pill only scales and fades in from its smaller, more transparent hidden state.
- The pill does not translate during the reveal phase.

### Overdrag

- Once the row has moved past the revealed resting position, the row continues following the finger.
- Only in that overdrag region does the pill start translating.
- The pill translation is capped at `10pt` past its resting position, while the row can continue moving under the existing drag allowance.

### Release

- Releasing from overdrag springs both row and pill back to the revealed resting state.
- Releasing before reveal threshold springs closed as today.

## Implementation Shape

- Keep the working `WeaponSwipeRow` SwiftUI `DragGesture`.
- Introduce explicit constants for:
  - revealed row gap (`15pt`)
  - pill overdrag cap (`10pt`)
- Compute row resting offset from pill width, trailing inset, and the extra gap.
- Compute pill translation only from overdrag distance beyond the revealed row resting offset.
- Preserve single-open-row behavior and existing delete confirmation flow.
