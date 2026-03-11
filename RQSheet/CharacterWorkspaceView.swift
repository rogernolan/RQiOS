import SwiftUI
import UIKit

struct CharacterWorkspaceView: View {
    private enum WorkspaceTab: Hashable {
        case summary
        case combat
        case skills
        case runes
        case extras
    }

    enum ExtrasDestination: String, CaseIterable, Hashable {
        case magic
        case equipment
        case notes

        var title: String {
            switch self {
            case .magic:
                return "Magic"
            case .equipment:
                return "Equipment"
            case .notes:
                return "Notes"
            }
        }

        var runeName: String {
            switch self {
            case .magic:
                return "RuneMagic"
            case .equipment:
                return "RuneTrade"
            case .notes:
                return "RuneTruth"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let character: RQCharacter

    @State private var selectedTab: WorkspaceTab = .summary
    @State private var selectedExtrasDestination: ExtrasDestination?
    @State private var isShowingExtrasMenu = false
    @State private var lastMainTab: WorkspaceTab = .summary
    @State private var isEditingRunes = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: tabSelection) {
                    Tab(value: WorkspaceTab.summary) {
                        StatsOverviewView(character: character)
                    } label: {
                        tabLabel("Summary", image: "RuneMan")
                    }
                    Tab(value: WorkspaceTab.combat) {
                        CombatView(character: character)
                    } label: {
                        tabLabel("Combat", image: "RuneDeath")
                    }
                    Tab(value: WorkspaceTab.skills) {
                        SkillsView(character: character)
                    } label: {
                        tabLabel("Skills", image: "RuneMastery")
                    }
                    Tab(value: WorkspaceTab.runes) {
                        RunesView(character: character, isEditing: $isEditingRunes)
                    } label: {
                        tabLabel("Runes", image: "RuneInfinity")
                    }
                    Tab(value: WorkspaceTab.extras) {
                        CharacterMoreTabView(
                            character: character,
                            selectedDestination: $selectedExtrasDestination,
                            onBack: dismissWorkspace
                        )
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(selectedTab == .extras ? .hidden : .visible, for: .navigationBar)
                .toolbar {
                    if selectedTab != .extras {
                        ToolbarItem(placement: .principal) {
                            Text(currentTitle)
                                .font(.headline)
                                .foregroundStyle(isPlaceholderTitle ? .secondary : .primary)
                        }

                        ToolbarItem(placement: .topBarTrailing) {
                            trailingToolbarItem
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)

                if isShowingExtrasMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isShowingExtrasMenu = false
                        }

                    MorePopupMenu(
                        notchInsetFromTrailingEdge: max(28, (geometry.size.width / 10) + 18),
                        destinations: ExtrasDestination.allCases,
                        onSelect: { destination in
                            selectedExtrasDestination = destination
                            selectedTab = .extras
                            isShowingExtrasMenu = false
                        },
                        onDismiss: {
                            isShowingExtrasMenu = false
                        }
                    )
                    .padding(.trailing, 4)
                    .padding(.bottom, 58)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
                }

                MoreTabProxyButton(width: geometry.size.width / 5) {
                    isShowingExtrasMenu = true
                }
                .zIndex(3)
            }
            .animation(.easeInOut(duration: 0.16), value: isShowingExtrasMenu)
        }
    }

    private var tabSelection: Binding<WorkspaceTab> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == .extras {
                    guard selectedExtrasDestination != nil else {
                        isShowingExtrasMenu = true
                        selectedTab = lastMainTab
                        return
                    }
                    selectedTab = .extras
                } else {
                    selectedTab = newValue
                    lastMainTab = newValue
                }
            }
        )
    }

    private var currentTitle: String {
        switch selectedTab {
        case .summary:
            let trimmedName = character.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedName.isEmpty ? "New character" : trimmedName
        case .combat:
            return "Combat"
        case .skills:
            return "Skills"
        case .runes:
            return "Rune affinities"
        case .extras:
            return selectedExtrasDestination?.title ?? "More"
        }
    }

    private var isPlaceholderTitle: Bool {
        selectedTab == .summary && character.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    private var trailingToolbarItem: some View {
        switch selectedTab {
        case .summary:
            NavigationLink {
                CharacterEditorView(character: character)
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.headline)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit character details")
        case .runes:
            Button {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isEditingRunes.toggle()
                }
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.headline)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isEditingRunes ? "Finish editing runes" : "Edit runes")
        case .combat, .skills, .extras:
            EmptyView()
        }
    }

    @ViewBuilder
    private func tabLabel(_ title: String, image: String) -> some View {
        if let uiImage = resizedTabIcon(named: image) {
            Label {
                Text(title)
            } icon: {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
            }
        } else {
            Label(title, systemImage: "circle")
        }
    }

    private func dismissWorkspace() {
        dismiss()
    }

    private func resizedTabIcon(named name: String, size: CGSize = CGSize(width: 22, height: 22)) -> UIImage? {
        guard let original = UIImage(named: name) else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { _ in
            original.draw(in: CGRect(origin: .zero, size: size))
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
}

private struct CharacterMoreTabView: View {
    let character: RQCharacter
    @Binding var selectedDestination: CharacterWorkspaceView.ExtrasDestination?
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let selectedDestination {
                WorkspaceInlineHeader(
                    title: selectedDestination.title,
                    onBack: onBack
                )

                destinationView(for: selectedDestination)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: CharacterWorkspaceView.ExtrasDestination) -> some View {
        switch destination {
        case .magic:
            MagicView(character: character)
        case .equipment:
            EquipmentView(character: character)
        case .notes:
            NotesView(character: character)
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

            Text(title)
                .font(.headline)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

private struct MorePopupMenu: View {
    let notchInsetFromTrailingEdge: CGFloat
    let destinations: [CharacterWorkspaceView.ExtrasDestination]
    let onSelect: (CharacterWorkspaceView.ExtrasDestination) -> Void
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
                    .frame(width: width, height: 70)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .ignoresSafeArea(edges: .bottom)
    }
}
