//
//  MotorPower.swift
//  lego_sample
//
//  Created by nao on 2024/04/24.
//

import Foundation

struct MotorPower: OutputMessage {
    let power: Int8
    let port: Port
    let messageType: MessageType = MessageType.portOutputCommand
    
    func write(writer: BytesWriter) {
        writer.writePort(port)
        writer.writeUInt8(0x11)
        writer.writeUInt8(0x51) //direct buffer
        writer.writeUInt8(0x00)
        writer.writeInt8(power)
    }
}
