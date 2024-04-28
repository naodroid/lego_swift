//
//  SensorMode.swift
//  lego_sample
//
//  Created by nao on 2024/04/29.
//

import Foundation

// https://github.com/bricklife/BoostBLEKit/blob/master/Sources/BoostBLEKit/IOType.swift
enum SensorMode {
    
    enum TiltSensor: UInt8 {
        case tilt = 0
        case orientation2D = 1
        case impactCount = 2
    }
    enum MotionSensor: UInt8 {
        case distance = 0
        case count = 1
    }
    enum LargeMotor: UInt8 {
        case speed = 1
        case position = 2
        case absolutePosition = 3
    }
}
