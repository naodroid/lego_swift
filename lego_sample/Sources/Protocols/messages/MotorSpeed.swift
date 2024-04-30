//
//  MotorSpeed.swift
//  lego_sample
//
//  Created by nao on 2024/04/30.
//

import Foundation

struct MotorSpeed: OutputMessage {
    let port: Port
    let speed: Int8
    let power: Int8
    let messageType: MessageType = MessageType.portOutputCommand
    
    init(port: Port, speed: Int8, power: Int8 = 100) {
        self.port = port
        self.speed = speed
        self.power = power
    }
    init(port: Port, forBrake: Void) {
        self.port = port
        self.speed = 127
        self.power = 100
    }
    
    func write(writer: BytesWriter) {
        writer.writePort(port)
        writer.writeUInt8(0x11)
        writer.writeUInt8(0x07)
        writer.writeInt8(speed)
        writer.writeInt8(power)
        writer.writeUInt8(0) //profile
    }
}
