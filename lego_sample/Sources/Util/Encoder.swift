//
//  Encoder.swift
//  bt_sample
//
//  Created by 坂本　尚嗣 on 2024/04/16.
//

import Foundation

final class Encoder {
    static func encode(message: OutputMessage) -> Data {
        let data = message.toBytes()
        let len = data.count + 3
        //FIXME: support 2bytes data len
        let header: [UInt8] = [UInt8(len), message.hubId, message.messageType.rawValue]
        let out = header + data
        return Data(out)
    }
}

