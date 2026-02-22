//  RQCharacter.swift
//  RQSheet
//
//  Created by Roger Nolan on 21/02/2026.
//

import Foundation
import SwiftData

@Model
final class RQCharacter {
    var name: String
    var str: Int
    var con: Int
    var siz: Int
    var dex: Int
    var int: Int
    var pow: Int
    var cha: Int
    
    var worships: String
    var reputation: String
    var occupation: String
    var sol: String
    var income: Int
    var ransom: Int
    var powExperienceCheck: Bool
    

    var fireAffinity: RuneAffinity = RuneAffinity(name: "Fire", percentage: 0)
    var darknessAffinity = RuneAffinity(name: "Darkness", percentage: 0)
    var earthAffinity = RuneAffinity(name: "Earth", percentage: 0)
    var waterAffinity = RuneAffinity(name: "Water", percentage: 0)
    var airAffinity = RuneAffinity(name: "Air", percentage: 0)
    var moonAffinity = RuneAffinity(name: "Moon", percentage: 0)
    
    // Related pairs with 50% each and relatedRune set
    
    var (manAffinity,beastAffinity) = RuneAffinity.relatedPair(lhName: "Man", rhName: "Beast")
    var (fertilityAffinity, deathAffinity) = RuneAffinity.relatedPair(lhName: "Fertility", rhName: "Death")
    var (harmonyAffinity, disorderAffinity) = RuneAffinity.relatedPair(lhName: "Harmony", rhName: "Disorder")
    var (truthAffinity, IllusionAffinity) = RuneAffinity.relatedPair(lhName: "Truth", rhName: "Illusion")
    var (stasisAffinity, movementAffinity) = RuneAffinity.relatedPair(lhName: "Stasis", rhName: "Movement")

    func agilityBonus() -> Int {
        let values: [(String, Int)] = [("STR", str), ("SIZ", siz), ("DEX", dex)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "STR":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                case "SIZ":
                    switch value {
                    case ...4: return 5
                    case 5...16: return 0
                    case 17...20: return -5
                    default: return -5
                    }
                case "DEX":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                switch stat {
                case "STR", "DEX":
                    return steps * 5
                case "SIZ":
                    return -(steps * 5)
                default:
                    return 0
                }
            }()

            return total + base + stepBonus
        }
    }

    func communicationsBonus() -> Int {
        let values: [(String, Int)] = [("INT", int), ("POW", pow), ("CHA", cha)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "INT", "POW":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                case "CHA":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                return steps * 5
            }()

            return total + base + stepBonus
        }
    }

    func knoledgeBonus() -> Int {
        let values: [(String, Int)] = [("INT", int), ("POW", pow)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "INT":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                case "POW":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                return steps * 5
            }()

            return total + base + stepBonus
        }
    }

    func manipulationBonus() -> Int {
        let values: [(String, Int)] = [("STR", str), ("DEX", dex), ("INT", int), ("POW", pow)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "STR", "POW":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                case "DEX", "INT":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                return steps * 5
            }()

            return total + base + stepBonus
        }
    }

    func stealthBonus() -> Int {
        let values: [(String, Int)] = [("SIZ", siz), ("DEX", dex), ("INT", int), ("POW", pow)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "SIZ":
                    switch value {
                    case ...4: return 10
                    case 5...8: return 5
                    case 9...12: return 0
                    case 13...16: return -5
                    case 17...20: return -10
                    default: return -10
                    }
                case "DEX", "INT":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                case "POW":
                    switch value {
                    case ...4: return 5
                    case 5...16: return 0
                    case 17...20: return -5
                    default: return -5
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                switch stat {
                case "SIZ", "POW":
                    return -(steps * 5)
                case "DEX", "INT":
                    return steps * 5
                default:
                    return 0
                }
            }()

            return total + base + stepBonus
        }
    }

    func perceptionBonus() -> Int {
        let values: [(String, Int)] = [("INT", int), ("POW", pow)]

        return values.reduce(0) { total, item in
            let (stat, value) = item

            let base: Int = {
                switch stat {
                case "INT":
                    switch value {
                    case ...4: return -10
                    case 5...8: return -5
                    case 9...12: return 0
                    case 13...16: return 5
                    case 17...20: return 10
                    default: return 10
                    }
                case "POW":
                    switch value {
                    case ...4: return -5
                    case 5...16: return 0
                    case 17...20: return 5
                    default: return 5
                    }
                default:
                    return 0
                }
            }()

            let stepBonus: Int = {
                guard value >= 21 else { return 0 }
                let steps = ((value - 21) / 4) + 1
                return steps * 5
            }()

            return total + base + stepBonus
        }
    }
    
    init(name: String = "",
         worships: String = "", reputation: String = "", occupation: String = "", sol: String = "", income: Int = 0, ransom: Int = 1000, powExperienceCheck: Bool = false,
         runeAffinities: [RuneAffinity]? = nil) {
        self.name = name
        
        // TODO these are not real rolls.
        self.str = Int.random(in: 3...18) // 3d6
        self.con = Int.random(in: 3...18) // 3d6
        self.pow = Int.random(in: 3...18) // 3d6
        self.dex = Int.random(in: 3...18) // 3d6
        self.cha = Int.random(in: 3...18) // 3d6
        self.int = Int.random(in: 8...18) // 2d6+6
        self.siz = Int.random(in: 8...18) // 2d6+6
        
        self.worships = worships
        self.reputation = reputation
        self.occupation = occupation
        self.sol = sol
        self.income = income
        self.ransom = ransom
        self.powExperienceCheck = powExperienceCheck
            
    }

}
