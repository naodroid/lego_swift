//
//  HubActionMessage.swift
//  lego_sample
//
//  Created by 坂本　尚嗣 on 2024/04/26.
//

import Foundation

enum HubActionType: UInt8 {
    // downstream
    case switchOffHub = 0x01
    case disconnect = 0x02
    case vccPotControlOn = 0x03
    case vccPortControlOff = 0x04
    case activateBusyIndication = 0x05
    case resetBusyIndication = 0x06
    case shutdown = 0X2F  //Suggested for PRODUCTION USE ONLY!
    
    //upstream
    case hubWillSwitchOff = 0x30
    case hubWillDisconnect = 0x31
    case hubWillGoIntoBootMode = 0x32
}

struct HubActionMessage: OutputMessage, InputMessage {
    let messageType = MessageType.hubActions
    let actionType: HubActionType
    
    func toBytes() -> [UInt8] {
        let wr = BytesWriter()
        wr.writeUInt8(actionType.rawValue)
        return wr.output
    }
    static func create(with reader: BytesReader) -> HubActionMessage? {
        let value = reader.readUInt8()
        guard let type = HubActionType(rawValue: value) else {
            return nil
        }
        return HubActionMessage(actionType: type)
    }
}
