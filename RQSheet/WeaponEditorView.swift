import SwiftUI

struct WeaponEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var basePercentageText: String
    @State private var experienceCheck: Bool
    @State private var strikeRank: String
    @State private var damage: String
    @State private var maxHPText: String
    @State private var currentHPText: String
    @State private var encText: String
    @State private var type: WeaponType?
    @State private var range: String
    @State private var isEquipped: Bool

    let title: String
    let onSave: (String, Int, Bool, String, String, Int?, Int?, Int?, WeaponType?, String, Bool) -> Void

    init(
        title: String,
        name: String = "",
        basePercentage: Int = 0,
        experienceCheck: Bool = false,
        strikeRank: String = "",
        damage: String = "",
        hpMax: Int? = nil,
        hpCurrent: Int? = nil,
        enc: Int? = nil,
        type: WeaponType? = nil,
        range: String = "",
        isEquipped: Bool = false,
        onSave: @escaping (String, Int, Bool, String, String, Int?, Int?, Int?, WeaponType?, String, Bool) -> Void
    ) {
        self.title = title
        self.onSave = onSave
        _name = State(initialValue: name)
        _basePercentageText = State(initialValue: String(max(0, basePercentage)))
        _experienceCheck = State(initialValue: experienceCheck)
        _strikeRank = State(initialValue: strikeRank)
        _damage = State(initialValue: damage)
        _maxHPText = State(initialValue: hpMax.map(String.init) ?? "")
        _currentHPText = State(initialValue: hpCurrent.map(String.init) ?? "")
        _encText = State(initialValue: enc.map(String.init) ?? "")
        _type = State(initialValue: type)
        _range = State(initialValue: range)
        _isEquipped = State(initialValue: isEquipped)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Weapon") {
                    LabeledContent("Name") {
                        TextField("Weapon", text: $name)
                            .multilineTextAlignment(.trailing)
                    }

                    Toggle("Equipped", isOn: $isEquipped)

                    Picker("Type", selection: $type) {
                        Text("-").tag(Optional<WeaponType>.none)
                        ForEach(WeaponType.allCases, id: \.self) { weaponType in
                            Text(weaponType.rawValue).tag(Optional(weaponType))
                        }
                    }
                }

                Section("Stats") {
                    LabeledContent("Base %") {
                        TextField("0", text: $basePercentageText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("SR") {
                        TextField("SR", text: $strikeRank)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Damage") {
                        TextField("e.g. 1d8+1", text: $damage)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Range") {
                        TextField("", text: $range)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Max HP") {
                        TextField("", text: $maxHPText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Current HP") {
                        TextField("", text: $currentHPText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("ENC") {
                        TextField("", text: $encText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .onChange(of: maxHPText) { _, _ in
                synchronizeCurrentHPWithMaxHP()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let (hpMax, hpCurrent) = resolvedHPValues()
                        onSave(
                            cleanName,
                            parsedBasePercentage,
                            experienceCheck,
                            cleanStrikeRank,
                            cleanDamage,
                            hpMax,
                            hpCurrent,
                            optionalIntValue(encText),
                            type,
                            cleanRange,
                            isEquipped
                        )
                        dismiss()
                    }
                }
            }
        }
    }

    private var cleanName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Weapon" : trimmed
    }

    private var cleanStrikeRank: String {
        strikeRank.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanDamage: String {
        let trimmed = damage.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "-" : trimmed
    }

    private var cleanRange: String {
        range.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedBasePercentage: Int {
        Int(basePercentageText.filter(\.isNumber)) ?? 0
    }

    private func resolvedHPValues() -> (Int?, Int?) {
        let trimmedMaxHP = maxHPText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCurrentHP = currentHPText.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedMaxHP = optionalIntValue(trimmedMaxHP)
        let parsedCurrentHP = optionalIntValue(trimmedCurrentHP)

        var resolvedCurrentHP = parsedCurrentHP
        if let hpMax = parsedMaxHP {
            if trimmedCurrentHP.isEmpty {
                resolvedCurrentHP = hpMax
            } else if let currentHP = parsedCurrentHP {
                resolvedCurrentHP = min(currentHP, hpMax)
            }
        }

        return (parsedMaxHP, resolvedCurrentHP)
    }

    private func synchronizeCurrentHPWithMaxHP() {
        let trimmedMaxHP = maxHPText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCurrentHP = currentHPText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let hpMax = optionalIntValue(trimmedMaxHP) else { return }

        if trimmedCurrentHP.isEmpty {
            currentHPText = maxHPText
        } else if let currentHP = optionalIntValue(trimmedCurrentHP) {
            currentHPText = String(min(currentHP, hpMax))
        }
    }

    private func optionalIntValue(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        return Int(trimmed.filter(\.isNumber))
    }
}
