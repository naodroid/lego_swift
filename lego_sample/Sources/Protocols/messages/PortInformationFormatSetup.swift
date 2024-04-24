//
//  PortInformationSetup.swift
//  lego_sample
//
//  Created by nao on 2024/04/24.
//

import Foundation

struct PortInformationFormatSetup: OutputMessage {
    let port: Port
    let messageType = MessageType.portInputFormatSetupSingle
    let mode: UInt8 = 0 //Fixed value?
    let deltaInterval: UInt32
    let enabled: Bool
    
    public func toBytes() -> [UInt8] {
        let wr = BytesWriter()
        wr.writePort(port)
        wr.writeUInt8(mode)
        wr.writeUInt32(deltaInterval)
        wr.writeBool(enabled)
        return wr.output
    }
}
