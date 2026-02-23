//
//  Int+Clamp.swift
//  RQSheet
//

import Foundation

extension Int {
    var clampedPercentage: Int {
        Swift.min(100, Swift.max(0, self))
    }
}
