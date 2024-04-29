//
//  File.swift
//  lego_sample
//
//  Created by nao on 2024/04/24.
//

import Foundation

class BytesWriter {
    private(set) var output = [UInt8]()
    init() {
    }
    
    func writePort(_ v: Port) {
        writeUInt8(v.id)
    }
    
    func writeBool(_ v: Bool) {
        writeUInt8(v ? 1 : 0)
    }
    func writeUInt8(_ v: UInt8) {
        output.append(v)
    }
    func writeInt8(_ v: Int8) {
        output.append(UInt8(bitPattern: v))
    }
    func writeUInt16(_ v: UInt16) {
        output.append(UInt8((v >> 8) & 0xFF))
        output.append(UInt8((v >> 0) & 0xFF))
    }
    func writeUInt32(_ v: UInt32) {
        output.append(UInt8((v >> 24) & 0xFF))
        output.append(UInt8((v >> 16) & 0xFF))
        output.append(UInt8((v >> 8) & 0xFF))
        output.append(UInt8((v >> 0) & 0xFF))
    }
    func writeInt32(_ v: Int32) {
        // it is wired that the order of byte-array reversed as UInt32.
        // however this works well in setAngle
        output.append(UInt8((v >> 0) & 0xFF))
        output.append(UInt8((v >> 8) & 0xFF))
        output.append(UInt8((v >> 16) & 0xFF))
        output.append(UInt8((v >> 24) & 0xFF))
    }
}
