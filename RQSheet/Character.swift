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
    
    init(name: String = "", str: Int = 0, con: Int = 0, dex: Int = 0, int: Int = 0, pow: Int = 0, siz: Int = 0, cha: Int = 0, xpChecks: Int = 0,
         worships: String = "", reputation: String = "", occupation: String = "", sol: String = "", income: Int = 0, ransom: Int = 1000) {
        self.name = name
        self.str = str
        self.con = con
        self.dex = dex
        self.int = int
        self.pow = pow
        self.siz = siz
        self.cha = cha
        
        self.worships = worships
        self.reputation = reputation
        self.occupation = occupation
        self.sol = sol
        self.income = income
        self.ransom = ransom
    }
}
