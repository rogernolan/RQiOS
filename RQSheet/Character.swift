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
