//
//  CharacterEditorView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

struct CharacterEditorView: View {
    @Bindable var character: RQCharacter

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text("Name")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                TextField("Name", text: Binding(
                    get: { character.name },
                    set: { newValue in
                        character.name = newValue
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                Text("Worships")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                TextField("Worships", text: Binding(
                    get: { character.worships },
                    set: { newValue in
                        character.worships = newValue
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    statField("STR", value: Binding(
                        get: { character.str },
                        set: { character.str = $0 }
                    ))
                    statField("INT", value: Binding(
                        get: { character.int },
                        set: { character.int = $0 }
                    ))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    statField("CON", value: Binding(
                        get: { character.con },
                        set: { character.con = $0 }
                    ))
                    statField("SIZ", value: Binding(
                        get: { character.siz },
                        set: { character.siz = $0 }
                    ))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    statField("DEX", value: Binding(
                        get: { character.dex },
                        set: { character.dex = $0 }
                    ))
                    statField("POW", value: Binding(
                        get: { character.pow },
                        set: { character.pow = $0 }
                    ))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    statField("CHA", value: Binding(
                        get: { character.cha },
                        set: { character.cha = $0 }
                    ))
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
                Text("Move")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                TextField(
                    "Move",
                    value: Binding<Int>(
                        get: { character.move },
                        set: { character.move = $0 }
                    ),
                    formatter: NumberFormatter()
                )
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(alignment: .top) {
                Text("Reputation")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                TextField(
                    "Reputation",
                    value: Binding<Int>(
                        get: { character.reputation },
                        set: { character.reputation = $0 }
                    ),
                    formatter: NumberFormatter()
                )
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                Text("Occupation")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                TextField("Occupation", text: Binding(
                    get: { character.occupation },
                    set: { newValue in character.occupation = newValue }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                Text("SoL")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                TextField("SoL", text: Binding(
                    get: { character.sol },
                    set: { newValue in character.sol = newValue }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                HStack(spacing: 4) {
                    Text("Income")
                        .font(.headline)
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
                    Text("L")
                        .font(.body)
                }
                .frame(minWidth: 0, maxWidth: .none, alignment: .leading)

                Spacer()
                    .frame(width: 24)

                HStack(spacing: 4) {
                    Text("Ransom")
                        .font(.headline)
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
                    Text("L")
                        .font(.body)
                }
                .frame(minWidth: 0, maxWidth: .none, alignment: .leading)
            }

            Spacer()
        }
        .padding(16)
        .navigationTitle("Edit Summary")
    }

    private func statField(_ label: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField("", value: value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 40)
                .textFieldStyle(.roundedBorder)
        }
    }
}
