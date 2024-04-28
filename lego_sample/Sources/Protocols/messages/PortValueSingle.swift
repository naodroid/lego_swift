//
//  PortValueSingle.swift
//  lego_sample
//
//  Created by nao on 2024/04/28.
//

import Foundation

enum PortValue {
    case uint8(value: UInt8)
    case uint16(value: UInt16)
    case float(value: Float)
}

struct PortValueSingle: InputMessage {
    let messageType = MessageType.portValueSingle
    let port: Port
    let value: [UInt8]
    
    static func create(reader: BytesReader) -> PortValueSingle? {
        let r = PortValueSingle(port: reader.readPort(),
                               value: reader.remainBytes())
        print("----------")
        print(r.value)
        print("----------")
        return r
    }
}
