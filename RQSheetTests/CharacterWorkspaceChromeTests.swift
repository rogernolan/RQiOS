import Testing
@testable import RQSheet

struct CharacterWorkspaceChromeTests {
    @Test
    func workspaceStartsOnSummary() {
        let navigation = WorkspaceNavigation()
        #expect(navigation.section == .summary)
        #expect(navigation.phoneTab == .summary)
        #expect(navigation.extrasSection == nil)
    }

    @Test
    func moreWithoutAnExtrasSelectionRequestsMenuAndKeepsCurrentSection() {
        var navigation = WorkspaceNavigation()
        navigation.select(.combat)
        let requestsMenu = navigation.selectPhoneTab(.extras)
        #expect(requestsMenu)
        #expect(navigation.section == .combat)
    }

    @Test(arguments: WorkspaceSection.extras)
    func extrasSelectionIsSharedWithPhoneMore(section: WorkspaceSection) {
        var navigation = WorkspaceNavigation()
        navigation.select(section)
        #expect(navigation.section == section)
        #expect(navigation.extrasSection == section)
        #expect(navigation.phoneTab == .extras)
        navigation.select(.skills)
        let requestsMenu = navigation.selectPhoneTab(.extras)
        #expect(requestsMenu == false)
        #expect(navigation.section == section)
    }

    @Test(arguments: [WorkspaceTab.summary, .combat, .skills, .runes])
    func phoneMainTabsSelectTheMatchingSection(tab: WorkspaceTab) {
        var navigation = WorkspaceNavigation()
        navigation.select(.notes)
        let requestsMenu = navigation.selectPhoneTab(tab)
        #expect(requestsMenu == false)
        #expect(navigation.section.rawValue == tab.rawValue)
        #expect(navigation.extrasSection == .notes)
    }

    @Test
    func newWorkspaceDoesNotInheritPreviousCharacterSelection() {
        var oldWorkspace = WorkspaceNavigation()
        oldWorkspace.select(.settings)
        let replacementWorkspace = WorkspaceNavigation()
        #expect(replacementWorkspace.section == .summary)
        #expect(replacementWorkspace.extrasSection == nil)
    }
}
