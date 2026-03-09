//
//  CombatView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

struct CombatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var characters: [RQCharacter]
    @State private var isPresentingAddWeapon = false

    var character: RQCharacter? {
        characters.first
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
                let panelHeight = max(360, geometry.size.width )

                ZStack {
                    Image("RuneMan")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(Color(.systemGray3))
                        .frame(maxWidth: .infinity)

                    if let character {
                        hitLocationOverlay(for: character)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: panelHeight)

                if let character {
                    Text("Total Hitpoints: \(character.currentHitpoints)/\(character.maxHitpoints)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }

                Divider()

                headerRow

                if let character {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(character.weapons) { weapon in
                                weaponRow(for: weapon)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 120)

                    Button("Add weapon") {
                        isPresentingAddWeapon = true
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Create a character in Summary to manage combat weapons.")
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .sheet(isPresented: $isPresentingAddWeapon) {
            if let character {
                AddWeaponView { name, basePercentage, damage, hpMax, hpCurrent, enc, strikeRank, type in
                    addWeapon(
                        to: character,
                        name: name,
                        basePercentage: basePercentage,
                        experienceCheck: false,
                        damage: damage,
                        hpMax: hpMax,
                        hpCurrent: hpCurrent,
                        enc: enc,
                        strikeRank: strikeRank,
                        type: type
                    )
                }
            }
        }
        .mainRuneBackground(runeName: "RuneDeath")
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text("Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("%")
                .frame(width: 64, alignment: .trailing)
            Text("Damage")
                .frame(width: 72, alignment: .trailing)
            Text("Type")
                .frame(width: 84, alignment: .trailing)
            Text("HP")
                .frame(width: 60, alignment: .trailing)
            Text("ENC")
                .frame(width: 40, alignment: .trailing)
            Text("SR")
                .frame(width: 52, alignment: .trailing)
        }
        .font(.caption)
        .fontWeight(.semibold)
    }

    private func weaponRow(for weapon: Weapon) -> some View {
        HStack(spacing: 8) {
            Text(weapon.name)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 4) {
                Text("\(weapon.basePercentage)%")
                Button {
                    weapon.experienceCheck.toggle()
                } label: {
                    Image(systemName: weapon.experienceCheck ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.plain)
            }
            .frame(width: 64, alignment: .trailing)
            Text(weapon.damage)
                .lineLimit(1)
                .frame(width: 72, alignment: .trailing)
            Text(weaponTypeText(for: weapon))
                .lineLimit(1)
                .frame(width: 84, alignment: .trailing)
            Text(weaponHPText(for: weapon))
                .frame(width: 60, alignment: .trailing)
            Text(weaponEncText(for: weapon))
                .frame(width: 40, alignment: .trailing)
            Text(weaponStrikeRankText(for: weapon))
                .frame(width: 52, alignment: .trailing)
        }
        .font(.footnote)
    }

    private func weaponTypeText(for weapon: Weapon) -> String {
        weapon.type?.rawValue ?? "-"
    }

    private func weaponHPText(for weapon: Weapon) -> String {
        guard let hpMax = weapon.hpMax, let hpCurrent = weapon.hpCurrent else { return "-" }
        return "\(hpMax)/\(hpCurrent)"
    }

    private func weaponEncText(for weapon: Weapon) -> String {
        guard let enc = weapon.enc else { return "-" }
        return "\(enc)"
    }

    private func weaponStrikeRankText(for weapon: Weapon) -> String {
        return weapon.strikeRank.isEmpty ? "-" : weapon.strikeRank
    }

    private func hitLocationOverlay(for character: RQCharacter) -> some View {
        GeometryReader { geo in
            let locationsByType = Dictionary(uniqueKeysWithValues: character.hitLocations.map { ($0.location, $0) })
            let yOffset: CGFloat = 20
            ZStack {
                hitLocationCard(locationsByType[.head])
                    .position(x: geo.size.width * 0.50, y: (geo.size.height * 0.15) + yOffset)
                hitLocationCard(locationsByType[.chest])
                    .position(x: geo.size.width * 0.50, y: (geo.size.height * 0.40) + yOffset )
                hitLocationCard(locationsByType[.abdomen])
                    .position(x: geo.size.width * 0.50, y: (geo.size.height * 0.65) + yOffset )
                hitLocationCard(locationsByType[.leftArm])
                    .position(x: (geo.size.width * 0.20) , y: (geo.size.height * 0.40) + yOffset )
                hitLocationCard(locationsByType[.rightArm])
                    .position(x: (geo.size.width * 0.80) , y: (geo.size.height * 0.40) + yOffset )
                hitLocationCard(locationsByType[.leftLeg])
                    .position(x: (geo.size.width * 0.25) , y: (geo.size.height * 0.80) + yOffset )
                hitLocationCard(locationsByType[.rightLeg])
                    .position(x: (geo.size.width * 0.75) , y: (geo.size.height * 0.80) + yOffset )
            }
        }
    }

    private func hitLocationCard(_ location: CharacterHitLocation?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(shortName(for: location?.location))
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 4) {
                Text("AP")
                    .font(.footnote)
                    .frame(width: 18, alignment: .leading)
                TextField(
                    "",
                    text: Binding<String>(
                        get: { armourText(for: location) },
                        set: { newValue in
                            guard let location else { return }
                            let digits = newValue.filter(\.isNumber)
                            if digits.isEmpty {
                                location.armour = 0
                            } else if let value = Int(digits) {
                                location.armour = value
                            }
                        }
                    )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.footnote.monospacedDigit())
                .textFieldStyle(.roundedBorder)
                .frame(width: 34)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 2)

            HStack(spacing: 4) {
                Text("HP")
                    .font(.footnote)
                    .frame(width: 18, alignment: .leading)
                TextField(
                    "",
                    text: Binding<String>(
                        get: { currentHPText(for: location) },
                        set: { newValue in
                            guard let location else { return }
                            let digits = newValue.filter(\.isNumber)
                            if digits.isEmpty {
                                location.currentHP = 0
                            } else if let value = Int(digits) {
                                location.currentHP = value
                            }
                        }
                    )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.footnote.monospacedDigit())
                .textFieldStyle(.roundedBorder)
                .frame(width: 34)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 2)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
        .frame(width: 85, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func shortName(for location: HitLocation?) -> String {
        switch location {
        case .head: return "Head"
        case .chest: return "Chest"
        case .abdomen: return "Abd"
        case .leftArm: return "L Arm"
        case .rightArm: return "R Arm"
        case .leftLeg: return "L Leg"
        case .rightLeg: return "R Leg"
        case .none: return "-"
        }
    }

    private func currentHPText(for location: CharacterHitLocation?) -> String {
        guard let location else { return "" }
        return String(location.currentHP)
    }

    private func armourText(for location: CharacterHitLocation?) -> String {
        guard let location else { return "" }
        return String(location.armour)
    }

    private func addWeapon(
        to character: RQCharacter,
        name: String,
        basePercentage: Int,
        experienceCheck: Bool,
        damage: String,
        hpMax: Int?,
        hpCurrent: Int?,
        enc: Int?,
        strikeRank: String,
        type: WeaponType?
    ) {
        let weapon = Weapon(
            character: character,
            name: name,
            basePercentage: basePercentage,
            experienceCheck: experienceCheck,
            damage: damage,
            hpMax: hpMax,
            hpCurrent: hpCurrent,
            enc: enc,
            strikeRank: strikeRank,
            type: type
        )
        modelContext.insert(weapon)
        character.weapons.append(weapon)
    }
}

private struct AddWeaponView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var basePercentage = "0"
    @State private var damage = ""
    @State private var hpMax = ""
    @State private var hpCurrent = ""
    @State private var enc = ""
    @State private var strikeRank = ""
    @State private var type: WeaponType? = nil

    let onSave: (String, Int, String, Int?, Int?, Int?, String, WeaponType?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Weapon") {
                    LabeledContent("Name") {
                        TextField("Weapon", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Type", selection: $type) {
                        Text("-").tag(Optional<WeaponType>.none)
                        ForEach(WeaponType.allCases, id: \.self) { weaponType in
                            Text(weaponType.rawValue).tag(Optional(weaponType))
                        }
                    }
                    LabeledContent("Damage") {
                        TextField("e.g. 1d8+1", text: $damage)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Stats") {
                    LabeledContent("Base %") {
                        TextField("0", text: $basePercentage)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("HP Max") {
                        TextField("", text: $hpMax)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("HP Current") {
                        TextField("", text: $hpCurrent)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("ENC") {
                        TextField("", text: $enc)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Strike Rank (SR)") {
                        TextField("SR", text: $strikeRank)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Add Weapon")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            normalizedName,
                            intValue(basePercentage, fallback: 0),
                            damage.isEmpty ? "-" : damage,
                            optionalIntValue(hpMax),
                            optionalIntValue(hpCurrent),
                            optionalIntValue(enc),
                            normalizedStrikeRank,
                            optionalWeaponType
                        )
                        dismiss()
                    }
                }
            }
        }
    }

    private var normalizedName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Weapon" : trimmed
    }

    private var normalizedStrikeRank: String {
        strikeRank.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var optionalWeaponType: WeaponType? {
        type
    }

    private func intValue(_ text: String, fallback: Int) -> Int {
        Int(text.filter(\.isNumber)) ?? fallback
    }

    private func optionalIntValue(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        return Int(trimmed.filter(\.isNumber))
    }
}
