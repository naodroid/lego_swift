//
//  HubPropertyMessage.swift
//  lego_sample
//
//  Created by nao on 2024/04/25.
//

import Foundation

enum HubPropertyReference: UInt8 {
    case advertisingName = 0x01
    case button = 0x02
    case fwVersion = 0x03
    case hwVersion = 0x04
    case RSSI = 0x05
    case batteryVoltage = 0x06
    case batteryType = 0x07
    case manufacturerName = 0x08
    case radioFirmwareVersion = 0x09
    case legoWirelessProtocolVersion = 0x0A
    case systemTypeID = 0x0B
    case hwNetworkID = 0x0C
    case primaryMacAddress = 0x0D
    case secondaryMacAddress = 0x0E
    case hwNetworkFamily = 0x0F
}
enum HubPropertyOperation: UInt8 {
    case set = 0x01    //Set (Downstream)
    case enable = 0x02    //Enable Updates (Downstream)
    case disable = 0x03    //Disable Updates (Downstream)
    case reset = 0x04    //Reset (Downstream)
    case request = 0x05    //Request Update (Downstream)
    case update = 0x06    //Update (Upstream)
}
enum HubPropertyPayload {
    case advertisingName(name: String)
    case button(state: Bool)
    case fwVersion(version: Int32)
    case hwVersion(version: Int32)
    case RSSI(rssi: Int8)
    case batteryVoltage(voltage: UInt8)
    case batteryType(type: UInt8) //0:normal, 1:rechargeable
    case manufacturerName(name: [UInt8]) //15bytes
    case radioFirmwareVersion(version: [UInt8])
    case legoWirelessProtocolVersion(version: UInt16)
    case systemTypeID(id: UInt8)
    case hwNetworkID(id: UInt8)
    case primaryMacAddress(addr: [UInt8]) //6bytes
    case secondaryMacAddress(addr: [UInt8]) //6bytes
    case hwNetworkFamily(family: UInt8)
}

struct HubPropertyMessage: InputMessage, OutputMessage {
    let messageType: MessageType = .hubProperties
    let operation: HubPropertyOperation
    let payload: HubPropertyPayload
    
    func write(writer: BytesWriter) {
        switch payload {
        case .advertisingName(let name):
            if name.isEmpty {
                print("Name must be 1char at least")
                return
            }
            for c in name {
                if let v = c.asciiValue {
                    writer.writeUInt8(v)
                }
            }
        default:
            // nothing to write
            return
        }
    }
    static func create(reader: BytesReader) -> HubPropertyMessage? {
        guard
            let payloadType = HubPropertyReference(rawValue: reader.readUInt8()),
            let operation = HubPropertyOperation(rawValue: reader.readUInt8()),
            let payload = readPayload(reader: reader, payloadType: payloadType)
        else {
            return nil
        }
        return HubPropertyMessage(operation: operation, payload: payload)
    }
    private static func readPayload(reader: BytesReader,
                             payloadType: HubPropertyReference) -> HubPropertyPayload? {
        switch payloadType {
        case .advertisingName:
            let dat = reader.remainBytesAsData()
            guard let name = String(data: dat, encoding: .utf8) else {
                return nil
            }
            return HubPropertyPayload.advertisingName(name: name)
        case .button:
            return HubPropertyPayload.button(state: reader.readBool())
        case .fwVersion:
            return HubPropertyPayload.fwVersion(version: reader.readInt32())
        case .hwVersion:
            return HubPropertyPayload.hwVersion(version: reader.readInt32())
        case .RSSI:
            return HubPropertyPayload.RSSI(rssi: reader.readInt8())
        case .batteryVoltage:
            return HubPropertyPayload.batteryVoltage(voltage: reader.readUInt8())
        case .batteryType:
            return HubPropertyPayload.batteryType(type: reader.readUInt8())
        case .manufacturerName:
            let data = reader.readBytes(length: 15)
            return HubPropertyPayload.manufacturerName(name: data)
        case .radioFirmwareVersion:
            let data = reader.readBytes(length: 15)
            return HubPropertyPayload.radioFirmwareVersion(version: data)
        case .legoWirelessProtocolVersion:
            return HubPropertyPayload.legoWirelessProtocolVersion(version: reader.readUInt16())
        case .systemTypeID:
            return HubPropertyPayload.systemTypeID(id: reader.readUInt8())
        case .hwNetworkID:
            return HubPropertyPayload.hwNetworkID(id: reader.readUInt8())
        case .primaryMacAddress:
            let data = reader.readBytes(length: 6)
            return HubPropertyPayload.primaryMacAddress(addr: data)
        case .secondaryMacAddress:
            let data = reader.readBytes(length: 6)
            return HubPropertyPayload.secondaryMacAddress(addr: data)
        case .hwNetworkFamily:
            return HubPropertyPayload.hwNetworkID(id: reader.readUInt8())
        }
    }
}
