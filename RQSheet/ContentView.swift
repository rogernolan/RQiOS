//
//  ContentView.swift
//  RQSheet
//
//  Created by Roger Nolan on 21/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    var body: some View {
        TabView {
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "person")
                }
            AttributesView()
                .tabItem {
                    Label("Attributes", systemImage: "chart.bar")
                }
            SkillsView()
                .tabItem {
                    Label("Skills", systemImage: "list.bullet")
                }
            RunesView()
                .tabItem {
                    Label("Runes", systemImage: "sparkles")
                }
            EquipmentView()
                .tabItem {
                    Label("Equipment", systemImage: "backpack")
                }
        }
    }
}

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var characters: [RQCharacter]
    
    var character: RQCharacter? {
        characters.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if character == nil {
                Button("New Character") {
                    let newCharacter = RQCharacter()
                    modelContext.insert(newCharacter)
                }
            }
            
            HStack(alignment: .top) {
                Text("Name")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                if let character = character {
                    TextField("Name", text: Binding(
                        get: { character.name },
                        set: { newValue in
                            character.name = newValue
                        }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(false)
                } else {
                    TextField("Name", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(true)
                }
            }
            HStack(alignment: .top) {
                Text("Worships")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                if let character = character {
                    TextField("Worships", text: Binding(
                        get: { character.worships },
                        set: { newValue in
                            character.worships = newValue
                        }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(false)
                } else {
                    TextField("Worships", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(true)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("STR")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let character = character {
                            TextField(
                                "",
                                value: Binding<Int>(
                                    get: { character.str },
                                    set: { character.str = $0 }
                                ),
                                formatter: NumberFormatter()
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 40)
                            .textFieldStyle(.roundedBorder)
                        } else {
                            Text("\(character?.str ?? 0)")
                                .font(.body)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("INT")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let character = character {
                            TextField(
                                "",
                                value: Binding<Int>(
                                    get: { character.int },
                                    set: { character.int = $0 }
                                ),
                                formatter: NumberFormatter()
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 40)
                            .textFieldStyle(.roundedBorder)
                        } else {
                            Text("\(character?.int ?? 0)")
                                .font(.body)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CON")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let character = character {
                            TextField(
                                "",
                                value: Binding<Int>(
                                    get: { character.con },
                                    set: { character.con = $0 }
                                ),
                                formatter: NumberFormatter()
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 40)
                            .textFieldStyle(.roundedBorder)
                        } else {
                            Text("\(character?.con ?? 0)")
                                .font(.body)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SIZ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let character = character {
                            TextField(
                                "",
                                value: Binding<Int>(
                                    get: { character.siz },
                                    set: { character.siz = $0 }
                                ),
                                formatter: NumberFormatter()
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 40)
                            .textFieldStyle(.roundedBorder)
                        } else {
                            Text("\(character?.siz ?? 0)")
                                .font(.body)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DEX")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let character = character {
                            TextField(
                                "",
                                value: Binding<Int>(
                                    get: { character.dex },
                                    set: { character.dex = $0 }
                                ),
                                formatter: NumberFormatter()
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 40)
                            .textFieldStyle(.roundedBorder)
                        } else {
                            Text("\(character?.dex ?? 0)")
                                .font(.body)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("POW")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            if let character = character {
                                TextField(
                                    "",
                                    value: Binding<Int>(
                                        get: { character.pow },
                                        set: { character.pow = $0 }
                                    ),
                                    formatter: NumberFormatter()
                                )
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(minWidth: 40)
                                .textFieldStyle(.roundedBorder)
                            } else {
                                Text("\(character?.pow ?? 0)")
                                    .font(.body)
                            }
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .font(.body)
                                .padding(.leading, 4)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CHA")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let character = character {
                            TextField(
                                "",
                                value: Binding<Int>(
                                    get: { character.cha },
                                    set: { character.cha = $0 }
                                ),
                                formatter: NumberFormatter()
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 40)
                            .textFieldStyle(.roundedBorder)
                        } else {
                            Text("\(character?.cha ?? 0)")
                                .font(.body)
                        }
                    }
                    // Blank spacer for alignment
                    VStack(alignment: .leading, spacing: 2) {
                        Text(" ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(" ")
                            .font(.body)
                    }
                }
            }
            
            HStack(alignment: .top) {
                Text("Reputation")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                if let character = character {
                    TextField("Reputation", text: Binding(
                        get: { character.reputation },
                        set: { newValue in character.reputation = newValue }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(false)
                } else {
                    TextField("Reputation", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(true)
                }
            }
            HStack(alignment: .top) {
                Text("Occupation")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                if let character = character {
                    TextField("Occupation", text: Binding(
                        get: { character.occupation },
                        set: { newValue in character.occupation = newValue }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(false)
                } else {
                    TextField("Occupation", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(true)
                }
            }
            HStack(alignment: .top) {
                Text("SoL")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                if let character = character {
                    TextField("SoL", text: Binding(
                        get: { character.sol },
                        set: { newValue in character.sol = newValue }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(false)
                } else {
                    TextField("SoL", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(true)
                }
            }
            HStack(alignment: .top) {
                HStack(spacing: 4) {
                    Text("Income")
                        .font(.headline)
                    if let character = character {
                        TextField(
                            "",
                            text: Binding(
                                get: { String(character.income) },
                                set: { newValue in
                                    if let intVal = Int(newValue) {
                                        character.income = intVal
                                    } else if newValue.isEmpty {
                                        character.income = 0
                                    }
                                }
                            )
                        )
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 50)
                    } else {
                        Text("\(character?.income ?? 0) L")
                            .font(.body)
                    }
                    Text("L")
                        .font(.body)
                }
                .frame(minWidth: 0, maxWidth: .none, alignment: .leading)
                
                Spacer()
                    .frame(width: 24)
                
                HStack(spacing: 4) {
                    Text("Ransom")
                        .font(.headline)
                    if let character = character {
                        TextField(
                            "",
                            text: Binding(
                                get: { String(character.ransom) },
                                set: { newValue in
                                    if let intVal = Int(newValue) {
                                        character.ransom = intVal
                                    } else if newValue.isEmpty {
                                        character.ransom = 0
                                    }
                                }
                            )
                        )
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 50)
                    } else {
                        Text("\(character?.ransom ?? 0) L")
                            .font(.body)
                    }
                    Text("L")
                        .font(.body)
                }
                .frame(minWidth: 0, maxWidth: .none, alignment: .leading)
            }

            Spacer()
        }
        .padding(16)
    }
}

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

                    PairRuneRowView(leftRune: character.fertilityAffinity, rightRune: character.harmonyAffinity)
                    PairRuneRowView(leftRune: character.truthAffinity, rightRune: character.stasisAffinity)
                    PairRuneRowView(leftRune: character.deathAffinity, rightRune: character.disorderAffinity)
                    PairRuneRowView(leftRune: character.IllusionAffinity, rightRune: character.movementAffinity)

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
    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

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
                    value: Binding<Int>(
                        get: { rune.percentage },
                        set: { rune.percentage = min(100, max(0, $0)) }
                    ),
                    formatter: Self.percentageFormatter
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

struct AttributesView: View {
    var body: some View {
        Text("Attributes pane")
    }
}

struct SkillsView: View {
    var body: some View {
        Text("Skills pane")
    }
}

struct EquipmentView: View {
    var body: some View {
        Text("Equipment pane")
    }
}

#Preview {
    ContentView().modelContainer(for: RQCharacter.self, inMemory: true)
}
