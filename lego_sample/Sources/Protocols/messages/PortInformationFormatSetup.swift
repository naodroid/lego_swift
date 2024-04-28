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
    let sensorMode: UInt8
    let deltaInterval: UInt32
    let enabled: Bool
    
    func write(writer: BytesWriter) {
        writer.writePort(port)
        writer.writeUInt8(sensorMode)
        writer.writeUInt32(deltaInterval)
        writer.writeBool(enabled)
    }
}
