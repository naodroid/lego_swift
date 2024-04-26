//
//  PortOutputCommand.swift
//  bt_sample
//
//  Created by 坂本　尚嗣 on 2024/04/16.
//

import Foundation

enum StartUpAndCompletionInfo: Int {
    case bufferAndNone = 0x0000
    case bufferAndFeedback = 0x0001
    case immediateAndNone = 0x0100
    case immediateAndFeedback = 0x0101
}

struct WriteDirectModeData {
    let data: [UInt8]
    static let modeHeader: UInt8 = 0x51
    static let mode: UInt8 = 0
    
    func toBytes() -> [UInt8] {
        return WriteDirectModeData.toDirectData(data)
    }
    static func toDirectData(_ data: [UInt8]) -> [UInt8] {
        return [modeHeader, mode] + data
    }
}


struct PortOutputCommand: OutputMessage {
    let messageType = MessageType.hubAlerts
    let port: Port
    let subCommand: SubCommand
    let startUpAndCompletionInfo: StartUpAndCompletionInfo
    
    func write(writer: BytesWriter) {
    }
}
protocol SubCommand {
    func toBytes() -> [UInt8]
}
struct StartPower: SubCommand {
    let power: UInt8
    let power2: UInt8?
    static let brake = 127
    static let floating = 0
    
    init(power: UInt8, power2: UInt8? = nil) {
        self.power = power
        self.power2 = power2
    }
    
    func toBytes() -> [UInt8] {
        if let power2 {
            return WriteDirectModeData.toDirectData([power, power2])
        }
        return WriteDirectModeData.toDirectData([power])
    }
}

