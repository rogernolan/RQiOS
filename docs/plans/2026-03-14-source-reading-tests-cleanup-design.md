# Source-Reading Tests Cleanup Design

## Problem

Several `RQSheetTests` suites read Swift source files directly from the repository at runtime using `String(contentsOf:)` and paths derived from `#filePath`. That pattern is brittle and currently fails under iOS XCTest sandboxing with `NSCocoaErrorDomain Code=257`, even when the product code is correct.

The current failures are not product regressions. They are test-architecture failures caused by treating source files as runtime fixtures.

## Goals

- Remove direct repository file reads from the chip-related source-reading tests first.
- Replace brittle source-string assertions with behavior, metric, or helper-based assertions wherever possible.
- Keep only a very small amount of structural coverage, and move that coverage onto test-bundle-owned resources or explicit exported configuration instead of repo path access.
- Leave `main` with tests that can run on the iOS destination without sandbox permission failures.

## Non-Goals

- Rewriting every source-reading test in the repository in one pass.
- Adding snapshot/UI screenshot infrastructure.
- Broadly refactoring product views beyond what is needed to expose testable constants or helpers.

## Recommended Approach

### 1. Convert chip-related suites away from source scanning

For the suites involved in the recent chip work:

- `RQSheetTests/EditableChipValueTests.swift`
- `RQSheetTests/CombatViewTests.swift`
- `RQSheetTests/MagicViewTests.swift`
- `RQSheetTests/RuneChipLayoutMetricsTests.swift`

replace source-file reads with one of these patterns:

- direct assertions on pure layout constants or helper functions
- extracted static configuration values owned by product code
- model-formatting/helper tests that verify the actual behavior we care about

This keeps the tests on runtime-visible API instead of implementation text.

### 2. Extract minimal testable configuration from product code

Where a current source-string assertion is really checking a constant or layout decision, move that decision into a small testable surface:

- scroll anchors
- chip widths / minimum widths
- animation constants
- completion-button travel distances
- top inset values

These should live as `private` only if the relevant test sits in the same file via a helper surface; otherwise expose them as small `internal` constants/types scoped narrowly to the view.

### 3. Keep structural checks only when behavior cannot cover intent

Some current assertions are really about structure, not behavior. For example, “this view uses the shared chip editor” can be important during a refactor. For those cases, prefer one of these:

- a tiny exported configuration/helper that proves the composition contract indirectly
- a bundled fixture/resource owned by the test target, if we absolutely need text inspection

The default should be to delete or replace structural string assertions, not preserve them automatically.

## Design By Suite

### EditableChipValueTests

This suite should stop reading `EditableChipValue.swift`.

Convert current checks into:

- direct tests of extracted animation constants
- tests of marker/accessory width policy through helper values
- tests of mode-specific formatting helpers, if needed

If the test needs to assert “hidden marker mode does not reserve idle width,” that should be verified through a helper or constant exposed by `EditableChipValue`, not by string-matching source.

### RuneChipLayoutMetricsTests

This suite is already closest to the desired pattern because many checks hit pure metrics directly.

Keep:

- width / height / spacing assertions on `RuneChipLayoutMetrics`
- chip radius / offset checks

Replace:

- `RunesView.swift` source reads for paired layout and top inset

with:

- direct testable configuration values exported from `RunesView` or related metrics

### MagicViewTests

This suite currently uses source scanning to prove:

- the search field exists
- shared chip editor is used
- scroll anchor is below the search header
- compact row formatting is in place

Refactor toward:

- testable `MagicViewLayout` constants or helper functions
- direct formatting helper assertions for points/page strings
- chip sizing constants tested directly

### CombatViewTests

Keep the tests that validate actual formatting behavior, such as strike rank text and optional display formatting.

Remove or replace source-string assertions for:

- exact SwiftUI structure
- exact animation modifier text
- exact composition strings

If a layout contract matters, extract a small helper/config surface instead of reading the whole file.

## Testing Strategy

For each affected suite:

1. Write or update a failing test that no longer reads repo files.
2. Verify the old source-reading assumption is no longer required.
3. Implement the smallest product/test helper needed to pass.
4. Run the focused suite on the iOS test destination.

Primary verification target:

```bash
xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet \
  -destination 'id=00006000-001810893A62801E' \
  -only-testing:RQSheetTests/RuneChipLayoutMetricsTests \
  -only-testing:RQSheetTests/EditableChipValueTests \
  -only-testing:RQSheetTests/CombatViewTests \
  -only-testing:RQSheetTests/MagicViewTests
```

Success means:

- no `Code=257` sandbox failures
- focused suites pass
- no new product-code regressions introduced

## Risks And Tradeoffs

### Risk: Over-preserving structural assertions

If we keep too many structure-only tests, we will just recreate the same brittleness through a different mechanism.

Mitigation:

- default to behavior/metric tests
- require justification for any remaining structural check

### Risk: Exposing too much test-only product surface

If we make too many internals public just for tests, product code gets noisy.

Mitigation:

- prefer narrow internal constants/helpers
- avoid broad test seams or debug-only code paths

### Risk: Scope expansion

There are many source-reading tests outside the chip area.

Mitigation:

- fix the chip-related suites first
- use the resulting pattern as the template for later cleanup

## Outcome

After this pass, the chip-related test suites should be runnable on simulator without repository file-access failures, and the project will have a clearer testing direction:

- behavior where behavior matters
- metrics where layout constants matter
- minimal structural coverage only where truly necessary
