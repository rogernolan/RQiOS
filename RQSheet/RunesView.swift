//
//  RunesView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

struct RunesView: View {
    @Query private var characters: [RQCharacter]

    var character: RQCharacter? {
        characters.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let character = character {
                RunicAffinitiesPentagramView(character: character)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Elemental affinities")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

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
                    .stroke(Color.secondary.opacity(0.35), lineWidth: 1)

                    RunicAffinityNodeView(rune: character.fireAffinity)
                        .position(top)

                    RunicAffinityNodeView(rune: character.darknessAffinity)
                        .position(upperRight)

                    RunicAffinityNodeView(rune: character.earthAffinity)
                        .position(lowerRight)

                    RunicAffinityNodeView(rune: character.waterAffinity)
                        .position(lowerLeft)

                    RunicAffinityNodeView(rune: character.airAffinity)
                        .position(upperLeft)

                    RunicAffinityNodeView(rune: character.moonAffinity)
                        .position(center)
                }
            }
            .frame(height: 280)

            PairedRunesSectionView(character: character)
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

struct PairedRunesSectionView: View {
    @Bindable var character: RQCharacter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Power Affinities")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.35))
                    .frame(width: 1, height: 246)

                VStack(spacing: 10) {
                    RunicAffinityNodeView(rune: character.manAffinity)
                        .frame(maxWidth: .infinity, alignment: .center)

                    PairRuneRowView(leftRune: character.fertilityAffinity, rightRune: character.deathAffinity)
                    PairRuneRowView(leftRune: character.harmonyAffinity, rightRune: character.disorderAffinity)
                    PairRuneRowView(leftRune: character.truthAffinity, rightRune: character.IllusionAffinity)
                    PairRuneRowView(leftRune: character.stasisAffinity, rightRune: character.movementAffinity)

                    RunicAffinityNodeView(rune: character.beastAffinity)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct PairRuneRowView: View {
    @Bindable var leftRune: RuneAffinity
    @Bindable var rightRune: RuneAffinity

    var body: some View {
        HStack(spacing: 8) {
            RunicAffinityNodeView(rune: leftRune)
                .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 52, height: 1)

            RunicAffinityNodeView(rune: rightRune)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct RunicAffinityNodeView: View {
    @Bindable var rune: RuneAffinity

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Text(rune.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Button {
                    rune.experienceCheck.toggle()
                } label: {
                    Image(systemName: rune.experienceCheck ? "checkmark.circle.fill" : "circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle \(rune.name) experience check")
            }

            HStack(spacing: 2) {
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
                .textFieldStyle(.roundedBorder)
                .frame(width: 48)

                Text("%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 82)
    }
}
