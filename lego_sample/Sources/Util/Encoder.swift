//
//  Encoder.swift
//  bt_sample
//
//  Created by 坂本　尚嗣 on 2024/04/16.
//

import Foundation

final class Encoder {
    static func encode(message: OutputMessage) -> Data {
        let writer = BytesWriter()
        writer.writeUInt8(0) //length, rewrite after message encoding
        writer.writeUInt8(message.hubId) //supposed to be zero
        writer.writeUInt8(message.messageType.rawValue)
        message.write(writer: writer)
        var data = writer.output
        data[0] = UInt8(data.count)
        return Data(data)
    }
}

