//
//  PortInformationMessage.swift
//  bt_sample
//
//  Created by 坂本　尚嗣 on 2024/04/19.
//

import Foundation

enum PortInformationMode: UInt8 {
    case name = 0
    case raw = 1
    case pct = 2
    case si = 3
    case symbol = 4
    case mapping = 5
    //case internally = 6
    case motorBias = 8
    case capabilityBits = 0x10
    case format = 0x80
}


struct PortInformationMessage: InputMessage {
    
    let messageType: MessageType = .portInformation
    
    static func create(reader: BytesReader) -> PortInformationMessage? {
        return nil
    }
}
