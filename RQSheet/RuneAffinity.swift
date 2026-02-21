//  RuneAffinity.swift
//  RQSheet
//
//  Created by Roger Nolan on 21/02/2026.
//

import Foundation
import SwiftData

@Model
final class RuneAffinity {
    var name: String
    var percentage: Int  // 0-100
    var experienceCheck: Bool
    var relatedRune: RuneAffinity?

    init(name: String, percentage: Int = 0, experienceCheck: Bool = false) {
        self.name = name
        self.percentage = percentage
        self.experienceCheck = experienceCheck
    }
    
    class func relatedPair(lhName:String ,rhName:String) -> (RuneAffinity,RuneAffinity) {
        let left = RuneAffinity(name: lhName, percentage: 50)
        let right = RuneAffinity(name: rhName, percentage: 50)
        left.relatedRune = right
        right.relatedRune = left
        return (left,right)
    }
}
