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
    var remainCount: Int { bytes.count - pos }
    
    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
    func readBool() -> Bool {
        return readUInt8() > 0
    }
    func readUInt8() -> UInt8 {
        let r = bytes[pos]
        pos += 1
        return r
    }
    func readInt8() -> Int8 {
        let r = readUInt8()
        return Int8(bitPattern: r)
    }
    func readUInt16() -> UInt16 {
        let b1 = UInt16(bytes[pos] & 0xFF)
        let b2 = UInt16(bytes[pos + 1] & 0xFF)
        pos += 2
        return (b2 << 8) | b1
    }
    func readInt32() -> Int32 {
        let b1 = Int32(bytes[pos] & 0xFF)
        let b2 = Int32(bytes[pos + 1] & 0xFF)
        let b3 = Int32(bytes[pos + 2] & 0xFF)
        let b4 = Int32(bytes[pos + 3] & 0xFF)
        return (b4 << 24) | (b3 << 16) | (b2 << 8) | b1
    }
    func readPort() -> Port {
        let id = readUInt8()
        return Port(id: id)
    }
    func readLength() -> Int {
        let r = readUInt8()
        if r & 0x80 > 0 {
            let b = readUInt8()
            return Int(b)
        }
        return Int(r)
    }
    func readBytes(length: Int) -> [UInt8] {
        let data = Array(bytes[pos..<(pos+length)])
        pos += length
        return data
    }
    func remainBytes() -> [UInt8] {
        let data = bytes[pos...]
        pos = bytes.count
        return Array(data)
    }
    func remainBytesAsData() -> Data {
        let data = remainBytes()
        return Data(data)
    }
    
}
