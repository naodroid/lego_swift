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
    
    func toBytes() -> [UInt8] {
        let wr = BytesWriter()
        wr.writePort(port)
        wr.writeUInt8(0x11)
        wr.writeUInt8(0x51) //direct buffer
        wr.writeUInt8(0x00)
        wr.writeInt8(power)      
        return wr.output
    }
}
