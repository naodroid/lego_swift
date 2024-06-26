//
//  MathUtil.swift
//  lego_sample
//
//  Created by nao on 2024/04/29.
//

import Foundation

enum MathUtil {
    
    /// normalize angle from -180 to 180 degree
    static func normalizeAngle(angle: Int32) -> Int32 {
        if (angle >= 180) {
            return angle - (360 * ((angle + 180) / 360))
        }
        if (angle < -180) {
            return angle + (360 * ((180 - angle) / 360))
        }
        return angle
    }
}

extension Comparable {
    func clamped(minValue: Self, maxValue: Self) -> Self {
        min(max(minValue, self), maxValue)
    }
    
    func clamped(to range: ClosedRange<Self>) -> Self {
        self.clamped(minValue: range.lowerBound, maxValue: range.upperBound)
    }
}
