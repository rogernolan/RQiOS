# iPad Workspace Implementation Plan

**Goal:** Give iPad a native section popover and readable content while preserving the iPhone tab bar.

**Architecture:** CharacterWorkspaceView chooses its shell by device idiom so narrow iPad windows retain the popover. A shared destination model owns section metadata and selection. The iPad shell hosts the current section within a centred 900-point content limit; Summary uses a compact profile.

**Tech stack:** SwiftUI, SwiftData, Swift Testing, XCTest UI tests, Xcode 27.0.

## Constraints

- Retain the iOS 26.2 deployment minimum.
- Keep all eight sections and the selected-character contract.
- Preserve the iPhone five-tab interface and More destinations.
- Preserve editing, importing, and persistence.

## Tasks

- [x] Add iPad UI coverage in RQSheetUITests/WorkspaceNavigationUITests.swift. Create a character, expect workspace.sectionMenu, open it, select every section, confirm no tab bar, and return to the list. Run on an iPad simulator and observe the missing-button failure.
- [x] Add RQSheet/WorkspaceNavigation.swift for all eight destination titles/icons, phone tab mapping, and navigation selection. Replace source-reading workspace chrome tests with state behaviour tests. Cover main tabs, More without a selected destination, switching extras, and Summary reset on character replacement.
- [x] Update RQSheet/CharacterWorkspaceView.swift to choose the iPad shell, present a native toolbar popover, reuse destination views, preserve phone tab content, and constrain iPad content to min(window width, 900). Add accessible identifiers to the section control and rows.
- [x] Update RQSheet/StatsOverviewView.swift with an iPad profile layout that bounds the portrait and places metadata beside it when space permits. Preserve the phone collapse animation. Test the width and compact-profile geometry at full and narrow widths.
- [x] Run focused unit tests and iPad UI tests. Run iPhone UI coverage through Summary, Combat, Skills, Runes, and every More destination. Check Summary editing and popover dismissal. Capture portrait and landscape screenshots for visual inspection, and report any verification limits.
- [x] Review the diff against the approved design, record verification results, and leave the change ready for Rog to review.

## Verification commands

```sh
rtk proxy xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=27.0' -derivedDataPath /private/tmp/rq-ipad-ui-build -parallel-testing-enabled NO -only-testing:RQSheetUITests/WorkspaceNavigationUITests CODE_SIGNING_ALLOWED=NO
rtk proxy xcodebuild test -project RQSheet.xcodeproj -scheme RQSheet -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' -derivedDataPath /private/tmp/rq-ipad-ui-build -parallel-testing-enabled NO -only-testing:RQSheetTests/CharacterWorkspaceChromeTests -only-testing:RQSheetTests/WorkspaceLayoutTests -only-testing:RQSheetUITests/WorkspaceNavigationUITests CODE_SIGNING_ALLOWED=NO
```

Use verified simulator identifiers if the installed device names differ. A passing run must exit zero and show all selected tests passing. Existing source-reading tests outside the changed workspace suites are a known limitation documented in the repository's earlier cleanup design.

## Completed verification and device delivery

On 8 October 2026, the focused simulator run passed 19 unit tests and four iPad UI tests, including every section, popover dismissal, Summary editing, import draft preservation, and portrait/landscape geometry. The separate iPhone UI test passed all four main tabs and all four More destinations. The result bundles are `/private/tmp/rq-ipad-final-20261008.xcresult` and `/private/tmp/rq-iphone-final-20261008.xcresult`. Portrait and landscape Summary screenshots and the native section popover were exported and inspected. Narrow-window geometry is covered by unit tests; interactive resized-window verification remains manual. The full legacy test suite was not run.

The review found that remounting the selected iPad section discarded unfinished import text. The iPad now retains stable section identities in a TabView with hidden tab chrome. The new import-draft regression first reproduced the loss, then passed with this change. The existing phone More proxy also missed part of the floating native tab button; its hit area was extended and its accessible control labelled. The phone regression passed after that fix.

A signed Release build succeeded using the iOS 27 SDK with the iOS 26.2 minimum. Code-signature verification passed. `com.diffeng.RQSheet` version 1.0 (build 1) was installed and launched successfully on Rog's iPad, Quittenförmiger Gulderling, UDID `00008132-000204862169001C`, running iPadOS 27.0. The existing application identity and persistence configuration were retained.
