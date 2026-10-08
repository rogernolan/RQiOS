import SwiftUI
import UIKit

struct CharacterWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss

    let character: RQCharacter
    let onOpenCharacter: (RQCharacter) -> Void

    @State private var navigation = WorkspaceNavigation()
    @State private var isShowingExtrasMenu = false
    @State private var isShowingSectionMenu = false

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        Group {
            if isPad {
                tabletWorkspace
            } else {
                phoneWorkspace
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isPad || navigation.phoneTab != .extras ? .visible : .hidden, for: .navigationBar)
        .toolbar {
            if isPad || navigation.phoneTab != .extras {
                ToolbarItem(placement: .principal) {
                    Text(currentTitle)
                        .font(.headline)
                        .foregroundStyle(isPlaceholderTitle ? .secondary : .primary)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if isPad {
                        sectionMenuButton
                    }
                    if navigation.section == .summary {
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
            // The hidden tab host retains each section's draft and scroll state.
            TabView(selection: sectionSelection) {
                ForEach(WorkspaceSection.allCases, id: \.self) { section in
                    Tab(value: section) {
                        sectionView(section)
                            .frame(width: WorkspaceLayout.contentWidth(availableWidth: geometry.size.width, isPad: true))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .toolbar(.hidden, for: .tabBar)
                    } label: {
                        Text(section.title)
                    }
                }
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }

    private var sectionSelection: Binding<WorkspaceSection> {
        Binding(get: { navigation.section }, set: { navigation.select($0) })
    }

    private var sectionMenuButton: some View {
        Button {
            isShowingSectionMenu = true
        } label: {
            Label("Sections", systemImage: "line.3.horizontal")
        }
        .accessibilityLabel("Choose section")
        .accessibilityValue(navigation.section.title)
        .accessibilityIdentifier("workspace.sectionMenu")
        .popover(isPresented: $isShowingSectionMenu, arrowEdge: .top) {
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(WorkspaceSection.allCases, id: \.self) { section in
                        Button {
                            navigation.select(section)
                            isShowingSectionMenu = false
                        } label: {
                            HStack(spacing: 12) {
                                Image(section.runeName)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                Text(section.title)
                                Spacer(minLength: 0)
                                if section == navigation.section {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("workspace.section.\(section.rawValue)")
                        .accessibilityAddTraits(section == navigation.section ? .isSelected : [])
                    }
                }
                .padding(8)
            }
            .frame(width: 280, height: 410)
            .presentationCompactAdaptation(.popover)
        }
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
        navigation.section == .summary && character.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sectionView(_ section: WorkspaceSection) -> some View {
        WorkspaceSectionView(character: character, section: section, onOpenCharacter: onOpenCharacter)
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
