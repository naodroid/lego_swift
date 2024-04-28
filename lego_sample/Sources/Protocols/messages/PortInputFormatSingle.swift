//
//  PortInputFormatSingle.swift
//  lego_sample
//
//  Created by nao on 2024/04/28.
//

import Foundation

struct PortInputFormatSingle: InputMessage {
    let messageType = MessageType.portInputFormatSingle
    let port: Port
    let mode: UInt8
    let deltaInterval: UInt32
    let enabled: Bool
    
    static func create(reader: BytesReader) -> PortInputFormatSingle? {
        let r = PortInputFormatSingle(port: reader.readPort(),
                                     mode: reader.readUInt8(),
                                     deltaInterval: reader.readUInt32(),
                                     enabled: reader.readBool())
        print(r)
        return r
    }
}
