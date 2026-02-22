//
//  SummaryView.swift
//  RQSheet
//

import SwiftUI
import SwiftData

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
                    _ = SkillSeeder.createCharacter(in: modelContext)
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
