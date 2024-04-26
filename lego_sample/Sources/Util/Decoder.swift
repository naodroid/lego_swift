//
//  Decoder.swift
//  lego_sample
//
//  Created by nao on 2024/04/25.
//

import Foundation

class Decoder {
    private let reader: BytesReader
    init(bytes: [UInt8]) {
        self.reader = BytesReader(bytes: bytes)
    }
    
    static func decode(_ data: Data) -> InputMessage? {
        let bytes = data.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) -> [UInt8] in
            let addr = ptr.assumingMemoryBound(to: UInt8.self).baseAddress!
            return [UInt8](UnsafeBufferPointer(start: addr, count: data.count))
        })
        let reader = BytesReader(bytes: bytes)
        _ /*len*/ = reader.readUInt8()
        _ /*mode*/ = reader.readUInt8() //this should be zero
        let typeValue = reader.readUInt8()
        guard let messageType = MessageType(rawValue: typeValue) else {
            print("Unimplemented:\(typeValue)")
            return nil
        }
        print("MESSAGE:\(messageType)")
        switch messageType {
            
        case .hubProperties:
            return nil
        case .hubActions:
            return nil
        case .hubAlerts:
            return nil
        case .hubAttachedIO:
            return HubAttachedIO.create(reader: reader)
        case .genericErrorMessages:
            return nil
        case .hwNetWorkCommands:
            return nil
        case .fwUpdateGoIntoBooMode:
            return nil
        case .fwUpdateLockMemory:
            return nil
        case .fwUpdateLockStatusRequest:
            return nil
        case .fwLockStatus:
            return nil
        case .portInformationRequest:
            return nil
        case .portModeInformationRequest:
            return nil
        case .portInputFormatSetupSingle:
            return nil
        case .portInputFormatSetupCombinedMode:
            return nil
        case .portInformation:
            return nil
        case .portModeInformation:
            return nil
        case .portValueSingle:
            return nil
        case .portValueCombinedMode:
            return nil
        case .portInputFormatSingle:
            return nil
        case .portInputFormatCombinedMode:
            return nil
        case .virtualPortSetup:
            return nil
        case .portOutputCommand:
            return nil
        case .portOutputCommandFeedback:
            return nil
        }
    }
}
