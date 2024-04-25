//
//  HubPropertyMessage.swift
//  lego_sample
//
//  Created by nao on 2024/04/25.
//

import Foundation

enum HubPropertyOperation: UInt8 {
    case set = 0x01    //Set (Downstream)
    case enable = 0x02    //Enable Updates (Downstream)
    case disable = 0x03    //Disable Updates (Downstream)
    case reset = 0x04    //Reset (Downstream)
    case request = 0x05    //Request Update (Downstream)
    case update = 0x06    //Update (Upstream)
}
enum HubPropertyReference: UInt8 {
    case advertisingName = 0x01
    case button = 0x02
    case fwVersion = 0x03
    case hwVersion = 0x04
    case RSSI = 0x05
    case batteryVoltage = 0x06
    case batteryType = 0x07
    case manufacturerName = 0x08
    case radioFirmwareVersion = 0x09
    case legoWirelessProtocolVersion = 0x0A
    case systemTypeID = 0x0B
    case hwNetworkID = 0x0C
    case primaryMacAddress = 0x0D
    case secondaryMacAddress = 0x0E
    case hardwareNetworkFamily = 0x0F
}
//struct HubPropertyMessage: InputMessage {
//    let messageType: MessageType = .hubProperties
//}
