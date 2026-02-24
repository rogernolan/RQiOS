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
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .overlay(
                        ZStack {
                            Image("RuneMan")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundStyle(Color(.systemGray3))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(5)

                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        }
                    )
                    .frame(height: max(180, geometry.size.height * 0.45))

                headerRow

                if let character {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(character.weaponSkills) { weapon in
                                weaponRow(for: weapon)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

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
                AddWeaponView { name, basePercentage, experienceCheck, damage, hpMax, hpCurrent, enc, strikeRank, type in
                    addWeapon(
                        to: character,
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
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text("Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("%")
                .frame(width: 64, alignment: .trailing)
            Text("Damage")
                .frame(width: 72, alignment: .trailing)
            Text("HP (M/C)")
                .frame(width: 74, alignment: .trailing)
            Text("SR")
                .frame(width: 32, alignment: .trailing)
        }
        .font(.caption)
        .fontWeight(.semibold)
    }

    private func weaponRow(for weapon: WeaponSkill) -> some View {
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
            Text("\(weapon.hpMax)/\(weapon.hpCurrent)")
                .frame(width: 74, alignment: .trailing)
            Text("\(weapon.strikeRank)")
                .frame(width: 32, alignment: .trailing)
        }
        .font(.footnote)
    }

    private func addWeapon(
        to character: RQCharacter,
        name: String,
        basePercentage: Int,
        experienceCheck: Bool,
        damage: String,
        hpMax: Int,
        hpCurrent: Int,
        enc: Int,
        strikeRank: Int,
        type: WeaponType
    ) {
        let weapon = WeaponSkill(
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
        character.weaponSkills.append(weapon)
    }
}

private struct AddWeaponView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var basePercentage = "0"
    @State private var experienceCheck = false
    @State private var damage = ""
    @State private var hpMax = "1"
    @State private var hpCurrent = "1"
    @State private var enc = "0"
    @State private var strikeRank = "0"
    @State private var type: WeaponType = .slashing

    let onSave: (String, Int, Bool, String, Int, Int, Int, Int, WeaponType) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Weapon") {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(WeaponType.allCases, id: \.self) { weaponType in
                            Text(weaponType.rawValue).tag(weaponType)
                        }
                    }
                    TextField("Damage", text: $damage)
                }

                Section("Stats") {
                    TextField("Base %", text: $basePercentage)
                        .keyboardType(.numberPad)
                    Toggle("Experience Check", isOn: $experienceCheck)
                    TextField("HP Max", text: $hpMax)
                        .keyboardType(.numberPad)
                    TextField("HP Current", text: $hpCurrent)
                        .keyboardType(.numberPad)
                    TextField("ENC", text: $enc)
                        .keyboardType(.numberPad)
                    TextField("Strike Rank (SR)", text: $strikeRank)
                        .keyboardType(.numberPad)
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
                            experienceCheck,
                            damage.isEmpty ? "-" : damage,
                            max(1, intValue(hpMax, fallback: 1)),
                            max(1, intValue(hpCurrent, fallback: 1)),
                            max(0, intValue(enc, fallback: 0)),
                            max(0, intValue(strikeRank, fallback: 0)),
                            type
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

    private func intValue(_ text: String, fallback: Int) -> Int {
        Int(text.filter(\.isNumber)) ?? fallback
    }
}
