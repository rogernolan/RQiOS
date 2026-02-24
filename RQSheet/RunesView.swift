//
//  RunesView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

struct RunesView: View {
    @Query private var characters: [RQCharacter]
    @State private var isEditing = false

    var character: RQCharacter? {
        characters.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let character = character {
                RunicAffinitiesPentagramView(character: character, isEditing: $isEditing)
            } else {
                Text("Create a character in Summary to view runic affinities.")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
    }
}

struct RunicAffinitiesPentagramView: View {
    @Bindable var character: RQCharacter
    @Binding var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isEditing {
                Spacer()
                    .frame(height: 10)
            }

            HStack(alignment: .center) {
                Text("Elemental affinities")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isEditing.toggle()
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.headline)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isEditing ? "Finish editing runes" : "Edit runes")
            }

            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let center = CGPoint(x: width / 2, y: height / 2)
                let radius = min(width, height) * 0.38

                let top = point(center: center, radius: radius, angleDegrees: -90)
                let upperRight = point(center: center, radius: radius, angleDegrees: -18)
                let lowerRight = point(center: center, radius: radius, angleDegrees: 54)
                let lowerLeft = point(center: center, radius: radius, angleDegrees: 126)
                let upperLeft = point(center: center, radius: radius, angleDegrees: 198)

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

                    RunicAffinityNodeView(rune: character.fireAffinity, isEditing: isEditing)
                        .position(top)

                    RunicAffinityNodeView(rune: character.darknessAffinity, isEditing: isEditing)
                        .position(upperRight)

                    RunicAffinityNodeView(rune: character.earthAffinity, isEditing: isEditing)
                        .position(lowerRight)

                    RunicAffinityNodeView(rune: character.waterAffinity, isEditing: isEditing)
                        .position(lowerLeft)

                    RunicAffinityNodeView(rune: character.airAffinity, isEditing: isEditing)
                        .position(upperLeft)

                    RunicAffinityNodeView(rune: character.moonAffinity, isEditing: isEditing)
                        .position(center)
                }
            }
            .frame(height: 280)

            PairedRunesSectionView(character: character, isEditing: isEditing)
        }
        .animation(.easeInOut(duration: 0.1), value: isEditing)
    }

    private func point(center: CGPoint, radius: CGFloat, angleDegrees: Double) -> CGPoint {
        let radians = angleDegrees * .pi / 180
        return CGPoint(
            x: center.x + CGFloat(cos(radians)) * radius,
            y: center.y + CGFloat(sin(radians)) * radius
        )
    }
}

struct PairedRunesSectionView: View {
    @Bindable var character: RQCharacter
    let isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Power Affinities")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 3, height: 246)

                VStack(spacing: 8) {
                    RunicAffinityNodeView(rune: character.manAffinity, isEditing: isEditing)
                        .frame(maxWidth: .infinity, alignment: .center)

                    PairRuneRowView(leftRune: character.fertilityAffinity, rightRune: character.deathAffinity, isEditing: isEditing)
                    PairRuneRowView(leftRune: character.harmonyAffinity, rightRune: character.disorderAffinity, isEditing: isEditing)
                    PairRuneRowView(leftRune: character.truthAffinity, rightRune: character.IllusionAffinity, isEditing: isEditing)
                    PairRuneRowView(leftRune: character.stasisAffinity, rightRune: character.movementAffinity, isEditing: isEditing)

                    RunicAffinityNodeView(rune: character.beastAffinity, isEditing: isEditing)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct PairRuneRowView: View {
    @Bindable var leftRune: RuneAffinity
    @Bindable var rightRune: RuneAffinity
    let isEditing: Bool

    var body: some View {
        HStack(spacing: 0) {
            RunicAffinityNodeView(rune: leftRune, isEditing: isEditing)

            Rectangle()
                .fill(Color.secondary.opacity(0.25))
                .frame(maxWidth: .infinity)
                .frame(height: 3)

            RunicAffinityNodeView(rune: rightRune, isEditing: isEditing)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct RunicAffinityNodeView: View {
    @Bindable var rune: RuneAffinity
    let isEditing: Bool

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
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
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle \(rune.name.rawValue) experience check")
            }
            .frame(maxWidth: .infinity)

            HStack(alignment: .center, spacing: 6) {
                Image(runeAssetName)
                    .resizable()
                    .scaledToFit()
                    .padding(1)
                    .frame(width: 26, height: 26, alignment: .leading)

                Spacer(minLength: 0)

                percentageView
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .frame(width: 97, alignment: .leading)
        .background(Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var percentageView: some View {
        if isEditing {
            HStack(spacing: 2) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemBackground))
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.systemGray4), lineWidth: 1)

                TextField(
                    "",
                    text: Binding<String>(
                        get: { String(rune.percentage) },
                        set: { newValue in
                            let digitsOnly = newValue.filter(\.isNumber)
                            if digitsOnly.isEmpty {
                                rune.setPercentage(0)
                            } else if let value = Int(digitsOnly) {
                                rune.setPercentage(value)
                            }
                        }
                    )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.callout.monospacedDigit())
                .padding(.horizontal, 6)
                }
                .frame(width: 52, height: 28)

                Text("%")
                    .font(.footnote.monospacedDigit())
                    .foregroundColor(.secondary)
            }
        } else {
            Text("\(rune.percentage)%")
                .font(.callout.monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 2)
        }
    }

    private var runeAssetName: String {
        "Rune\(rune.name.rawValue)"
    }
}
