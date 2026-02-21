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
                    // TODO these are not real rolls.
                    newCharacter.str = Int.random(in: 3...18) // 3d6
                    newCharacter.con = Int.random(in: 3...18) // 3d6
                    newCharacter.pow = Int.random(in: 3...18) // 3d6
                    newCharacter.dex = Int.random(in: 3...18) // 3d6
                    newCharacter.cha = Int.random(in: 3...18) // 3d6
                    newCharacter.int = Int.random(in: 8...18) // 2d6+6
                    newCharacter.siz = Int.random(in: 8...18) // 2d6+6
                    modelContext.insert(newCharacter)
                }
            }
            
            HStack(alignment: .top) {
                Text("Name")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                if let character = character {
                    TextField("Name", text: Binding(
                        get: { character.name ?? "" },
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
                Text(character?.worships ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                Text(character?.reputation ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                Text("Occupation")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                Text(character?.occupation ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                Text("SoL")
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                Text(character?.sol ?? "—")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top) {
                HStack(spacing: 4) {
                    Text("Income")
                        .font(.headline)
                    Text("\(character?.income ?? 0) L")
                        .font(.body)
                }
                .frame(minWidth: 0, maxWidth: .none, alignment: .leading)
                
                Spacer()
                    .frame(width: 24)
                
                HStack(spacing: 4) {
                    Text("Ransom")
                        .font(.headline)
                    Text("\(character?.ransom ?? 0) L")
                        .font(.body)
                }
                .frame(minWidth: 0, maxWidth: .none, alignment: .leading)
            }
            Spacer()
        }
        .padding(16)
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

