# iPad workspace navigation

Status: approved on 7 October 2026, including the content adjustments.

The iPad workspace will replace the tab bar with a section button in the top toolbar. The button will open a native popover containing Summary, Combat, Skills, Runes, Magic, Equipment, Notes, and Settings, with rune icons and a mark beside the current section. Choosing a section will dismiss the popover and show that section in the workspace. The navigation back button will return to the character list. Summary will retain its edit action.

The iPhone will retain Summary, Combat, Skills, Runes, and More in its tab bar, including access to the four existing More destinations. Both device layouts will use the same selected character and destination state. Selecting another character will open its Summary. The iPad will keep its popover navigation when its window becomes narrow; content will fit the available width.

The recommended content adjustment will give iPad Summary a compact portrait beside its profile details instead of a portrait that expands to the window width. Workspace content will have a maximum width of 900 points and remain centred in wider windows. Narrow windows will use the existing single-column content. Existing editing, importing, and persistence behaviour will remain intact.

The alternative scope is navigation only: add the iPad section popover and preserve the existing content layouts. A standard toolbar Menu is another implementation option, but an explicit popover provides control over the destination rows and current-selection mark.

The project currently requires iOS 26.2. The installed Xcode 27.0 provides the iOS 27 SDK. The implementation will use that SDK while retaining the current minimum unless a required API needs a higher version.

Verification will cover every iPad destination, popover dismissal and selection, return to the character list, Summary editing, and iPhone tab navigation including More. Simulator checks will cover iPad portrait, landscape, a narrow window, and iPhone. Behaviour tests will exercise navigation state and layout decisions rather than inspect source text. Existing relevant tests will run, and any pre-existing failures will be reported separately.
