//
//  MotorAngle.swift
//  lego_sample
//
//  Created by nao on 2024/04/29.
//

import Foundation

struct MotorAngle: OutputMessage {
    let port: Port
    let angle: Int32
    let maxSpeed: Int8
    let maxPower: Int8
    let endState: EndState
    let messageType: MessageType = MessageType.portOutputCommand
    
    init(port: Port, 
         angle: Int32,
         maxSpeed: Int8 = 100,
         maxPower: Int8 = 100,
         endState: EndState = .hold) {
        self.port = port
        self.angle = angle
        self.maxSpeed = maxSpeed
        self.maxPower = maxPower
        self.endState = endState
    }
    
    func write(writer: BytesWriter) {
        writer.writePort(port)
        writer.writeUInt8(0x11)
        writer.writeUInt8(0x0d)
        writer.writeInt32(angle)
        writer.writeInt8(maxSpeed)
        writer.writeInt8(maxPower)
        writer.writeInt8(endState.rawValue)
        writer.writeUInt8(0) //use profile
    }
}


