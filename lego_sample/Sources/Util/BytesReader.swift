//
//  BytesReader.swift
//  bt_sample
//
//  Created by 坂本　尚嗣 on 2024/04/19.
//

import Foundation

class BytesReader {
    var pos: Int = 0
    let bytes: [UInt8]
    
    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
    func readUInt8() -> UInt8 {
        let r = bytes[pos]
        pos += 1
        return r
    }
    func readUInt16() -> UInt16 {
        let b1 = UInt16(bytes[pos] & 0xFF)
        let b2 = UInt16(bytes[pos + 1] & 0xFF)
        pos += 2
        return (b1 << 16) | b2
    }
    func readPort() -> Port {
        let r = readUInt8()
        return Port(rawValue: r)!
    }
    func readLength() -> Int {
        let r = readUInt8()
        if r & 0x80 > 0 {
            let b = readUInt8()
            return Int(b)
        }
        return Int(r)
    }
}
