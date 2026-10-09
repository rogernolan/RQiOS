//
//  RunesView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

enum RuneViewConfiguration {
    static let horizontalPadding: CGFloat = 16
    static let topPadding: CGFloat = 8
    static let scrollAnchor: UnitPoint = .center
}

struct RunesView: View {
    @Environment(\.characterSectionPresentation) private var presentation
    @Environment(\.characterSectionScrollToEditor) private var scrollToEditor
    let character: RQCharacter
    @StateObject private var keyboard = KeyboardHeightObserver()
    @State private var activeEditorAnchor: RuneEditorAnchor?

    var body: some View {
        Group {
            if presentation.isTile {
                RunicAffinitiesPentagramView(character: character, activeEditorAnchor: $activeEditorAnchor)
            } else {
                pageContent
            }
        }
        .sectionRuneBackground(runeName: "RuneInfinity", fixedRotation: 50)
    }

    private var pageContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    RunicAffinitiesPentagramView(
                        character: character,
                        activeEditorAnchor: $activeEditorAnchor
                    )
                }
                .padding(.horizontal, RuneViewConfiguration.horizontalPadding)
                .padding(.top, RuneViewConfiguration.topPadding)
                .padding(.bottom, keyboard.contentInset)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: activeEditorAnchor) { _, newAnchor in
                guard let newAnchor else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(newAnchor, anchor: RuneViewConfiguration.scrollAnchor)
                }
            }
        }
    }
}

enum RuneEditorAnchor: String, Hashable {
    case elemental
    case power
}

struct RunicAffinitiesPentagramView: View {
    @Environment(\.characterSectionPresentation) private var presentation
    @Environment(\.characterSectionScrollToEditor) private var scrollToEditor
    @Bindable var character: RQCharacter
    @Binding var activeEditorAnchor: RuneEditorAnchor?

    var body: some View {
        if presentation.isTile {
            tileContent
        } else {
            diagramContent
        }
    }

    private var tileContent: some View {
        let width = presentation.tileWidth ?? 360
        let compact = width < 340
        return IntrinsicRuneTileLayout(isCompact: compact) {
            ForEach(Array((elementalRunes + pairedRunes).enumerated()), id: \.offset) { index, rune in
                OptionalRunicAffinityNodeView(
                    rune: rune,
                    layoutStyle: index < 6 ? .elemental : .paired,
                    onBeginEditing: {
                        if let rune { scrollToEditor(AnyHashable(rune.id)) }
                    },
                    onEndEditing: {}
                )
                .id(index)
            }
        }
        .background {
            if !compact {
                GeometryReader { geometry in
                    let metrics = RuneTileGeometry(width: geometry.size.width, isCompact: false)
                    Path { path in
                        path.addEllipse(in: CGRect(
                            x: geometry.size.width / 2 - metrics.elementalRadius,
                            y: metrics.elementalHeight / 2 - metrics.elementalRadius,
                            width: metrics.elementalRadius * 2,
                            height: metrics.elementalRadius * 2
                        ))
                        path.move(to: CGPoint(x: geometry.size.width / 2, y: metrics.elementalHeight + 6 + 29))
                        path.addLine(to: CGPoint(x: geometry.size.width / 2, y: metrics.height - 29))
                        for row in 1...4 {
                            let y = metrics.elementalHeight + 6 + 29 + CGFloat(row) * 66
                            path.move(to: CGPoint(x: 62, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width - 62, y: y))
                        }
                    }
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 3)
                }
                .allowsHitTesting(false)
            }
        }
    }

    private var elementalRunes: [RuneAffinity?] {
        [character.fireAffinity, character.darknessAffinity, character.earthAffinity,
         character.waterAffinity, character.airAffinity, character.moonAffinity]
    }

    private var pairedRunes: [RuneAffinity?] {
        [character.manAffinity, character.fertilityAffinity, character.deathAffinity,
         character.harmonyAffinity, character.disorderAffinity, character.truthAffinity,
         character.IllusionAffinity, character.stasisAffinity, character.movementAffinity,
         character.beastAffinity]
    }

    private var diagramContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let center = CGPoint(x: width / 2, y: height / 2)
                let defaultRadius = min(width, height) * RuneChipLayoutMetrics.elementalRadiusMultiplier
                let radius = presentation.isTile
                    ? min(defaultRadius, max(0, (width - RuneChipLayoutMetrics.chipWidth) / 1.91))
                    : defaultRadius

                let top = point(center: center, radius: radius, angleDegrees: -90)
                let upperRight = point(center: center, radius: radius, angleDegrees: -18)
                    .offsetBy(dy: RuneChipLayoutMetrics.upperSideNodeVerticalOffset)
                let lowerRight = point(center: center, radius: radius, angleDegrees: 54)
                let lowerLeft = point(center: center, radius: radius, angleDegrees: 126)
                let upperLeft = point(center: center, radius: radius, angleDegrees: 198)
                    .offsetBy(dy: RuneChipLayoutMetrics.upperSideNodeVerticalOffset)

                ZStack {
                    Path { path in
                        let arcAngles: [(start: Double, end: Double)] = [
                            (-90, -18),
                            (-18, 54),
                            (54, 126),
                            (126, 198),
                            (198, 270)
                        ]

                        for arc in arcAngles {
                            path.addArc(
                                center: center,
                                radius: radius,
                                startAngle: .degrees(arc.start),
                                endAngle: .degrees(arc.end),
                                clockwise: false
                            )
                        }
                    }
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 3)

                    OptionalRunicAffinityNodeView(
                        rune: character.fireAffinity,
                        layoutStyle: .elemental,
                        onBeginEditing: { activeEditorAnchor = .elemental },
                        onEndEditing: { activeEditorAnchor = nil }
                    )
                        .position(top)

                    OptionalRunicAffinityNodeView(
                        rune: character.darknessAffinity,
                        layoutStyle: .elemental,
                        onBeginEditing: { activeEditorAnchor = .elemental },
                        onEndEditing: { activeEditorAnchor = nil }
                    )
                        .position(upperRight)

                    OptionalRunicAffinityNodeView(
                        rune: character.earthAffinity,
                        layoutStyle: .elemental,
                        onBeginEditing: { activeEditorAnchor = .elemental },
                        onEndEditing: { activeEditorAnchor = nil }
                    )
                        .position(lowerRight)

                    OptionalRunicAffinityNodeView(
                        rune: character.waterAffinity,
                        layoutStyle: .elemental,
                        onBeginEditing: { activeEditorAnchor = .elemental },
                        onEndEditing: { activeEditorAnchor = nil }
                    )
                        .position(lowerLeft)

                    OptionalRunicAffinityNodeView(
                        rune: character.airAffinity,
                        layoutStyle: .elemental,
                        onBeginEditing: { activeEditorAnchor = .elemental },
                        onEndEditing: { activeEditorAnchor = nil }
                    )
                        .position(upperLeft)

                    OptionalRunicAffinityNodeView(
                        rune: character.moonAffinity,
                        layoutStyle: .elemental,
                        onBeginEditing: { activeEditorAnchor = .elemental },
                        onEndEditing: { activeEditorAnchor = nil }
                    )
                        .position(center)
                }
            }
            .frame(height: presentation.isTile ? max(280, (presentation.tileWidth ?? 360) * 0.78) : 280)
            .id(RuneEditorAnchor.elemental)

            PairedRunesSectionView(
                character: character,
                activeEditorAnchor: $activeEditorAnchor
            )
            .id(RuneEditorAnchor.power)
        }
    }

    private func point(center: CGPoint, radius: CGFloat, angleDegrees: Double) -> CGPoint {
        let radians = angleDegrees * .pi / 180
        return CGPoint(
            x: center.x + CGFloat(cos(radians)) * radius,
            y: center.y + CGFloat(sin(radians)) * radius
        )
    }
}

private extension CGPoint {
    func offsetBy(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
}

struct PairedRunesSectionView: View {
    @Bindable var character: RQCharacter
    @Binding var activeEditorAnchor: RuneEditorAnchor?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 3, height: 246)

                VStack(spacing: 8) {
                    OptionalRunicAffinityNodeView(
                        rune: character.manAffinity,
                        layoutStyle: .paired,
                        onBeginEditing: { activeEditorAnchor = .power },
                        onEndEditing: { activeEditorAnchor = nil }
                    )
                        .frame(maxWidth: .infinity, alignment: .center)

                    PairRuneRowView(
                        leftRune: character.fertilityAffinity,
                        rightRune: character.deathAffinity,
                        activeEditorAnchor: $activeEditorAnchor
                    )
                    PairRuneRowView(
                        leftRune: character.harmonyAffinity,
                        rightRune: character.disorderAffinity,
                        activeEditorAnchor: $activeEditorAnchor
                    )
                    PairRuneRowView(
                        leftRune: character.truthAffinity,
                        rightRune: character.IllusionAffinity,
                        activeEditorAnchor: $activeEditorAnchor
                    )
                    PairRuneRowView(
                        leftRune: character.stasisAffinity,
                        rightRune: character.movementAffinity,
                        activeEditorAnchor: $activeEditorAnchor
                    )

                    OptionalRunicAffinityNodeView(
                        rune: character.beastAffinity,
                        layoutStyle: .paired,
                        onBeginEditing: { activeEditorAnchor = .power },
                        onEndEditing: { activeEditorAnchor = nil }
                    )
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct PairRuneRowView: View {
    let leftRune: RuneAffinity?
    let rightRune: RuneAffinity?
    @Binding var activeEditorAnchor: RuneEditorAnchor?

    var body: some View {
        HStack(spacing: 0) {
            OptionalRunicAffinityNodeView(
                rune: leftRune,
                layoutStyle: .paired,
                onBeginEditing: { activeEditorAnchor = .power },
                onEndEditing: { activeEditorAnchor = nil }
            )

            Rectangle()
                .fill(Color.secondary.opacity(0.25))
                .frame(maxWidth: .infinity)
                .frame(height: 3)

            OptionalRunicAffinityNodeView(
                rune: rightRune,
                layoutStyle: .paired,
                onBeginEditing: { activeEditorAnchor = .power },
                onEndEditing: { activeEditorAnchor = nil }
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct RunicAffinityNodeView: View {
    enum LayoutStyle {
        case elemental
        case paired
    }

    @Bindable var rune: RuneAffinity
    let layoutStyle: LayoutStyle
    let onBeginEditing: () -> Void
    let onEndEditing: () -> Void
    @StateObject private var editorController = EditableChipValueController()

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: RuneChipLayoutMetrics.titleSpacing) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text(rune.name.rawValue)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    rune.experienceCheck.toggle()
                } label: {
                    Image(systemName: rune.experienceCheck ? "checkmark.circle.fill" : "circle")
                        .font(.caption2)
                        .frame(
                            width: RuneChipLayoutMetrics.checkboxSlotWidth,
                            height: RuneChipLayoutMetrics.checkboxSlotHeight
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle \(rune.name.rawValue) experience check")
            }
            .frame(maxWidth: .infinity)

            HStack(alignment: .center, spacing: RuneChipLayoutMetrics.valueRowSpacing) {
                Image(runeAssetName)
                    .resizable()
                    .scaledToFit()
                    .padding(1)
                    .frame(
                        width: RuneChipLayoutMetrics.runeIconSize,
                        height: RuneChipLayoutMetrics.runeIconSize,
                        alignment: .leading
                    )

                Spacer(minLength: 0)

                percentageView
                    .frame(height: RuneChipLayoutMetrics.percentageEditorHeight, alignment: .trailing)
                    .frame(width: percentageSlotWidth, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, minHeight: RuneChipLayoutMetrics.percentageEditorHeight)
        }
        .padding(.horizontal, RuneChipLayoutMetrics.chipHorizontalPadding)
        .padding(.vertical, RuneChipLayoutMetrics.chipVerticalPadding)
        .frame(
            width: chipWidth,
            height: RuneChipLayoutMetrics.chipHeight,
            alignment: .topLeading
        )
        .background(Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture {
            editorController.requestBeginEditing()
        }
    }

    @ViewBuilder
    private var percentageView: some View {
        EditableChipValue(
            mode: .singleValue,
            value: Binding(
                get: { rune.percentage },
                set: { rune.setPercentage($0) }
            ),
            displaySuffix: "%",
            showsEditingSuffix: false,
            isEnabled: true,
            textFieldWidth: 28,
            valueFont: .callout,
            markerPlacement: .hidden,
            controller: editorController,
            onBeginEditing: onBeginEditing,
            onEndEditing: onEndEditing
        )
        .frame(width: percentageDisplayWidth, alignment: .trailing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, RuneChipLayoutMetrics.percentageContentLeadingInset)
    }

    private var runeAssetName: String {
        "Rune\(rune.name.rawValue)"
    }

    private var chipWidth: CGFloat {
        switch layoutStyle {
        case .elemental:
            RuneChipLayoutMetrics.chipWidth
        case .paired:
            RuneChipLayoutMetrics.pairedChipWidth
        }
    }

    private var percentageDisplayWidth: CGFloat {
        switch layoutStyle {
        case .elemental:
            RuneChipLayoutMetrics.percentageDisplayWidth
        case .paired:
            RuneChipLayoutMetrics.pairedPercentageDisplayWidth
        }
    }

    private var percentageSlotWidth: CGFloat {
        switch layoutStyle {
        case .elemental:
            RuneChipLayoutMetrics.percentageSlotWidth(for: true)
        case .paired:
            RuneChipLayoutMetrics.pairedPercentageSlotWidth(for: true)
        }
    }
}

/// A missing link can occur while CloudKit is delivering the rest of a character.
struct OptionalRunicAffinityNodeView: View {
    let rune: RuneAffinity?
    let layoutStyle: RunicAffinityNodeView.LayoutStyle
    let onBeginEditing: () -> Void
    let onEndEditing: () -> Void

    @ViewBuilder var body: some View {
        if let rune {
            RunicAffinityNodeView(rune: rune, layoutStyle: layoutStyle,
                                  onBeginEditing: onBeginEditing, onEndEditing: onEndEditing)
        }
    }
}

/// Canonical nodes remain mounted while their placement changes with the tile width.
private struct IntrinsicRuneTileLayout: Layout {
    let isCompact: Bool

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 360
        return CGSize(width: width, height: RuneTileGeometry(width: width, isCompact: isCompact).height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let metrics = RuneTileGeometry(width: bounds.width, isCompact: isCompact)
        for (index, subview) in subviews.enumerated() {
            let point = metrics.position(of: index)
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), anchor: .center, proposal: .unspecified)
        }
    }
}

struct RuneTileGeometry {
    let width: CGFloat
    let isCompact: Bool
    var elementalHeight: CGFloat { max(320, width * 0.78) }
    var elementalRadius: CGFloat {
        min(min(width, elementalHeight) * RuneChipLayoutMetrics.elementalRadiusMultiplier,
            max(0, (width - RuneChipLayoutMetrics.chipWidth) / 1.91))
    }
    var height: CGFloat { isCompact ? 16 * 58 + 15 * 8 : elementalHeight + 6 + 6 * 58 + 5 * 8 }

    func position(of index: Int) -> CGPoint {
        if isCompact { return CGPoint(x: width / 2, y: 29 + CGFloat(index) * 66) }
        if index < 6 {
            let center = CGPoint(x: width / 2, y: elementalHeight / 2)
            guard index < 5 else { return center }
            let angles: [Double] = [-90, -18, 54, 126, 198]
            let angle = angles[index] * .pi / 180
            let offset = index == 1 || index == 4 ? RuneChipLayoutMetrics.upperSideNodeVerticalOffset : 0
            return CGPoint(x: center.x + CGFloat(cos(angle)) * elementalRadius,
                           y: center.y + CGFloat(sin(angle)) * elementalRadius + offset)
        }
        let pairedIndex = index - 6
        let row = pairedIndex == 0 ? 0 : pairedIndex == 9 ? 5 : (pairedIndex + 1) / 2
        let x: CGFloat = pairedIndex == 0 || pairedIndex == 9 ? width / 2 : pairedIndex.isMultiple(of: 2) ? width - 62 : 62
        return CGPoint(x: x, y: elementalHeight + 6 + 29 + CGFloat(row) * 66)
    }
}
