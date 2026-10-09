import SwiftUI
import UIKit

struct CharacterWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss

    let character: RQCharacter
    let onOpenCharacter: (RQCharacter) -> Void

    @State private var navigation = WorkspaceNavigation()
    @State private var isShowingExtrasMenu = false
    @State private var isShowingTabletSettings = false
    @StateObject private var keyboard = KeyboardOverlapObserver()
    @State private var workspaceWidth: CGFloat = 1024
    @State private var testViewportWidth: CGFloat?
    @State private var testViewportHeight: CGFloat?

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var showsTiles: Bool { isPad && workspaceWidth >= 680 }

    var body: some View {
        Group {
            if isPad {
                tabletWorkspace
            } else {
                phoneWorkspace
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(showsTiles || navigation.phoneTab != .extras ? .visible : .hidden, for: .navigationBar)
        .toolbar {
            if showsTiles || navigation.phoneTab != .extras {
                ToolbarItem(placement: .principal) {
                    Text(currentTitle)
                        .font(.headline)
                        .foregroundStyle(isPlaceholderTitle ? .secondary : .primary)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if isPad && ProcessInfo.processInfo.arguments.contains("-ui-testing-in-memory") && ProcessInfo.processInfo.arguments.contains("-ui-testing-enable-resize") {
                        Button("Resize") {
                            testViewportWidth = testViewportWidth == nil ? 500 : nil
                            testViewportHeight = nil
                        }
                        .accessibilityIdentifier("workspace.testResize")
                        Button("Narrow landscape") {
                            testViewportWidth = 700
                            testViewportHeight = 400
                        }
                        .accessibilityIdentifier("workspace.testNarrowLandscape")
                    }
                    if showsTiles {
                        Button { dismissKeyboard(); isShowingTabletSettings = true } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .accessibilityIdentifier("workspace.settings")
                    }
                    if showsTiles || navigation.section == .summary {
                        NavigationLink {
                            CharacterEditorView(character: character)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.headline)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Edit character details")
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var tabletWorkspace: some View {
        GeometryReader { geometry in
            let size = CGSize(width: testViewportWidth ?? geometry.size.width, height: testViewportHeight ?? geometry.size.height)
            let compact = size.width < 680
            let keyboardInset = keyboard.bottomInset(in: geometry.frame(in: .global))
            ZStack(alignment: .top) {
                IPadCharacterTilesView(character: character, windowSize: size, keyboardInset: keyboardInset)
                    .opacity(compact || isShowingTabletSettings ? 0 : 1)
                    .allowsHitTesting(!compact && !isShowingTabletSettings)
                    .accessibilityHidden(compact || isShowingTabletSettings)
                phoneWorkspace
                    .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: keyboardInset) }
                    .environment(\.horizontalSizeClass, .compact)
                    .opacity(compact && !isShowingTabletSettings ? 1 : 0)
                    .allowsHitTesting(compact && !isShowingTabletSettings)
                    .accessibilityHidden(!compact || isShowingTabletSettings)
                    .toolbar(compact && !isShowingTabletSettings ? .visible : .hidden, for: .tabBar)
                SettingsView(character: character, onOpenCharacter: onOpenCharacter)
                    .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: keyboardInset) }
                    .opacity(isShowingTabletSettings ? 1 : 0)
                    .allowsHitTesting(isShowingTabletSettings)
                    .accessibilityHidden(!isShowingTabletSettings)
                    .background(isShowingTabletSettings ? Color(.systemBackground) : Color.clear)
            }
            .frame(width: size.width, height: size.height, alignment: .top)
            .frame(maxWidth: .infinity)
            .onChange(of: size.width, initial: true) { _, width in workspaceWidth = width }
            .onChange(of: compact) { _, _ in dismissKeyboard() }
            .onChange(of: navigation.section) { _, section in
                if section == .settings {
                    dismissKeyboard()
                    isShowingTabletSettings = true
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .toolbar {
            if isShowingTabletSettings {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismissKeyboard()
                        isShowingTabletSettings = false
                        if navigation.section == .settings { navigation.select(.summary) }
                    }
                    .accessibilityIdentifier("workspace.closeSettings")
                }
            }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private var phoneWorkspace: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: tabSelection) {
                    Tab(value: WorkspaceTab.summary) {
                        sectionView(.summary)
                    } label: {
                        tabLabel("Summary", image: "RuneMan")
                    }
                    Tab(value: WorkspaceTab.combat) {
                        sectionView(.combat)
                    } label: {
                        tabLabel("Combat", image: "RuneDeath")
                    }
                    Tab(value: WorkspaceTab.skills) {
                        sectionView(.skills)
                    } label: {
                        tabLabel("Skills", image: "RuneMastery")
                    }
                    Tab(value: WorkspaceTab.runes) {
                        sectionView(.runes)
                    } label: {
                        tabLabel("Runes", image: "RuneInfinity")
                    }
                    Tab(value: WorkspaceTab.extras) {
                        VStack(spacing: 0) {
                            if let section = navigation.extrasSection {
                                WorkspaceInlineHeader(title: section.title, onBack: { dismiss() })
                                sectionView(section)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            }
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }

                if isShowingExtrasMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { isShowingExtrasMenu = false }

                    MorePopupMenu(
                        notchInsetFromTrailingEdge: max(28, (geometry.size.width / 10) + 18),
                        destinations: WorkspaceSection.extras,
                        onSelect: { section in
                            navigation.select(section)
                            isShowingExtrasMenu = false
                        },
                        onDismiss: { isShowingExtrasMenu = false }
                    )
                    .padding(.trailing, 4)
                    .padding(.bottom, 58)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
                }

                MoreTabProxyButton(width: geometry.size.width / 5 + 32) {
                    isShowingExtrasMenu = true
                }
                .zIndex(3)
            }
            .animation(.easeInOut(duration: 0.16), value: isShowingExtrasMenu)
        }
    }

    private var tabSelection: Binding<WorkspaceTab> {
        Binding(
            get: { navigation.phoneTab },
            set: { tab in
                if navigation.selectPhoneTab(tab) {
                    isShowingExtrasMenu = true
                }
            }
        )
    }

    private var currentTitle: String {
        if isPad && isShowingTabletSettings { return "Settings" }
        if showsTiles {
            let name = character.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return name.isEmpty ? "New character" : name
        }
        switch navigation.section {
        case .summary:
            let name = character.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return name.isEmpty ? "New character" : name
        case .runes:
            return "Rune affinities"
        default:
            return navigation.section.title
        }
    }

    private var isPlaceholderTitle: Bool {
        (showsTiles || navigation.section == .summary) && character.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sectionView(_ section: WorkspaceSection) -> some View {
        Group {
            if isPad && section == .settings {
                Color.clear
            } else {
                WorkspaceSectionView(character: character, section: section, onOpenCharacter: onOpenCharacter)
            }
        }
    }

    @ViewBuilder
    private func tabLabel(_ title: String, image: String) -> some View {
        if let uiImage = resizedTabIcon(named: image) {
            Label {
                Text(title)
            } icon: {
                Image(uiImage: uiImage).renderingMode(.template)
            }
        } else {
            Label(title, systemImage: "circle")
        }
    }

    private func resizedTabIcon(named name: String, size: CGSize = CGSize(width: 22, height: 22)) -> UIImage? {
        guard let original = UIImage(named: name) else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            original.draw(in: CGRect(origin: .zero, size: size))
        }.withRenderingMode(.alwaysTemplate)
    }
}

private struct WorkspaceSectionView: View {
    let character: RQCharacter
    let section: WorkspaceSection
    let onOpenCharacter: (RQCharacter) -> Void

    var body: some View {
        Group {
            switch section {
            case .summary: StatsOverviewView(character: character)
            case .combat: CombatView(character: character)
            case .skills: SkillsView(character: character)
            case .runes: RunesView(character: character)
            case .magic: MagicView(character: character)
            case .equipment: EquipmentView(character: character)
            case .notes: NotesView(character: character)
            case .settings: SettingsView(character: character, onOpenCharacter: onOpenCharacter)
            }
        }
    }
}

private struct WorkspaceInlineHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to characters")
            Text(title).font(.headline)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

private struct MorePopupMenu: View {
    let notchInsetFromTrailingEdge: CGFloat
    let destinations: [WorkspaceSection]
    let onSelect: (WorkspaceSection) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(destinations, id: \.self) { destination in
                Button {
                    onSelect(destination)
                } label: {
                    HStack(spacing: 12) {
                        Image(destination.runeName)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(.primary)

                        Text(destination.title)
                            .font(.body)
                            .foregroundStyle(.primary)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 8)
        .padding(.bottom, 18)
        .frame(width: 188)
        .background(.ultraThinMaterial, in: MorePopupBubbleShape(notchInsetFromTrailingEdge: notchInsetFromTrailingEdge))
        .overlay {
            MorePopupBubbleShape(notchInsetFromTrailingEdge: notchInsetFromTrailingEdge)
                .stroke(.quaternary.opacity(0.8), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.14), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .contain)
        .onDisappear(perform: onDismiss)
    }
}

private struct MorePopupBubbleShape: Shape {
    let notchInsetFromTrailingEdge: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 20
        let notchHalfWidth: CGFloat = 12
        let notchHeight: CGFloat = 14
        let bodyBottomY = rect.maxY - notchHeight
        let minNotchCenterX = rect.minX + cornerRadius + notchHalfWidth + 12
        let maxNotchCenterX = rect.maxX - cornerRadius - notchHalfWidth - 12
        let safeNotchCenterX = min(
            max(rect.maxX - notchInsetFromTrailingEdge, minNotchCenterX),
            maxNotchCenterX
        )

        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: bodyBottomY - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: bodyBottomY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: safeNotchCenterX + notchHalfWidth, y: bodyBottomY))
        path.addLine(to: CGPoint(x: safeNotchCenterX, y: rect.maxY))
        path.addLine(to: CGPoint(x: safeNotchCenterX - notchHalfWidth, y: bodyBottomY))
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: bodyBottomY))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: bodyBottomY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

private struct MoreTabProxyButton: View {
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)

            Button(action: action) {
                Color.clear
                    .frame(width: width, height: 100)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More sections")
            .accessibilityIdentifier("workspace.moreMenu")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .ignoresSafeArea(edges: .bottom)
    }
}
