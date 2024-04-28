//
//  MotorPower.swift
//  lego_sample
//
//  Created by nao on 2024/04/24.
//

import Foundation

struct MotorPower: OutputMessage {
    let port: Port
    let power: Int8
    let messageType: MessageType = MessageType.portOutputCommand
    
    init(port: Port, power: Int8) {
        self.port = port
        self.power = power
    }
    init(port: Port, forBrake: Void) {
        self.port = port
        self.power = 127
    }
    
    func write(writer: BytesWriter) {
        writer.writePort(port)
        writer.writeUInt8(0x11)
        writer.writeUInt8(0x51) //direct buffer
        writer.writeUInt8(0x00)
        writer.writeInt8(power)
    }
}
