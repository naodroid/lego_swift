//
//  Message.swift
//  bt_sample
//
//  Created by 坂本　尚嗣 on 2024/04/16.
//

import Foundation

protocol Message {
    var hubId: UInt8 { get }
    var messageType: MessageType { get }
}
extension Message {
    // hub ID must be zero
    var hubId: UInt8 { 0 }
}

protocol OutputMessage: Message {
    func toBytes() -> [UInt8]
}
protocol InputMessage: Message {
    static func fromBytes(_ bytes: [UInt8]) -> Self
}



enum MessageType: UInt8 {
    // HUB related
    case hubProperties = 0x01  //  Down + Up
    case hubActions = 0x02 //   Down + Up
    case hubAlerts = 0x03  //  Down + Up
    case hubAttachedIO = 0x04  //  Up
    case genericErrorMessages = 0x05  //  Up
    case hwNetWorkCommands = 0x08  //   Down + Up
    case fwUpdateGoIntoBooMode = 0x10  //  Down
    case fwUpdateLockMemory = 0x11   // Down
    case fwUpdateLockStatusRequest = 0x12 //Down
    case fwLockStatus = 0x13  //  Up
    
    //ports Related
    case portInformationRequest = 0x21 // Down
    case portModeInformationRequest = 0x22 // Down
    case portInputFormatSetupSingle = 0x41 // Down
    case portInputFormatSetupCombinedMode = 0x42  // Down
    case portInformation = 0x43  // Up
    case portModeInformation = 0x44 // Up
    case portValueSingle = 0x45  // Up
    case portValueCombinedMode = 0x46  // Up
    case portInputFormatSingle = 0x47 // Up
    case portInputFormatCombinedMode = 0x48 // Up
    case virtualPortSetup = 0x61 // Down
    case portOutputCommand = 0x81  // Down
    case portOutputCommandFeedback = 0x82  // Up
}



