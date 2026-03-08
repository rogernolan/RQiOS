# Equipment Editor Sheet Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the equipment push editor with a bottom sheet matching passions and weapons, using explicit Cancel/Save semantics for both add and edit.

**Architecture:** Equipment list presentation stays on the tab, but editor presentation moves to a shared sheet backed by local draft state. Add creates a new item only on Save; edit copies values into a draft and writes them back on Save so Cancel is non-destructive.

**Tech Stack:** SwiftUI, SwiftData, XCTest UI tests, Testing

---

### Task 1: Lock sheet behavior with failing tests

**Files:**
- Modify: `RQSheetUITests/RQSheetUITests.swift`
- Modify: `RQSheetTests/EquipmentEditorViewTests.swift`

**Step 1:** Add UI tests proving `Add new item` opens a bottom sheet and row tap opens the same sheet for edit.
**Step 2:** Add source-level tests proving the equipment editor matches the passions/weapons pattern (`NavigationStack`, `Form`, toolbar cancel/save).
**Step 3:** Run targeted tests and verify they fail against the current push editor.

### Task 2: Implement shared sheet editor

**Files:**
- Modify: `RQSheet/EquipmentView.swift`
- Modify: `RQSheet/EquipmentEditorView.swift`

**Step 1:** Remove the UIKit navigation-controller bridge and push flow.
**Step 2:** Add sheet state for add/edit presentation and local draft values.
**Step 3:** Convert the editor to a sheet-style `NavigationStack` + `Form` with Cancel/Save.
**Step 4:** Make Save create a new item for add and mutate the existing item for edit.

### Task 3: Verify regressions

**Files:**
- Verify: `RQSheetUITests/RQSheetUITests.swift`
- Verify: `RQSheetTests/EquipmentEditorViewTests.swift`

**Step 1:** Run targeted unit tests.
**Step 2:** Run targeted UI tests for add/edit equipment presentation.
**Step 3:** Run a build to ensure the feature compiles cleanly.
