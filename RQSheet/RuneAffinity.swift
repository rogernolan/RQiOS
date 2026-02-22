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
    private(set) var percentage: Int  // 0-100
    var experienceCheck: Bool
    var relatedRune: RuneAffinity?

    init(name: String, percentage: Int = 0, experienceCheck: Bool = false) {
        self.name = name
        self.percentage = min(100, max(0, percentage))
        self.experienceCheck = experienceCheck
    }

    func setPercentage(_ newValue: Int) {
        applyPercentage(newValue, syncPair: true)
    }

    private func applyPercentage(_ newValue: Int, syncPair: Bool) {
        let clampedValue = min(100, max(0, newValue))
        if percentage == clampedValue {
            return
        }

        percentage = clampedValue

        guard syncPair, let relatedRune else { return }

        let pairedValue = 100 - clampedValue
        if relatedRune.percentage != pairedValue {
            relatedRune.applyPercentage(pairedValue, syncPair: false)
        }
    }
    
    class func relatedPair(lhName:String ,rhName:String) -> (RuneAffinity,RuneAffinity) {
        let left = RuneAffinity(name: lhName, percentage: 50)
        let right = RuneAffinity(name: rhName, percentage: 50)
        left.relatedRune = right
        right.relatedRune = left
        return (left,right)
    }
}
