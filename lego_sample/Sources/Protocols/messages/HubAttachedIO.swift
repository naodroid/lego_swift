//
//  HubAttachedIO.swift
//  lego_sample
//
//  Created by nao on 2024/04/25.
//

import Foundation
enum AttachedEvent: UInt8 {
    case detachedIO = 0x00 //5bytes
    case attachedIO = 0x01 //15bytes
    case attachedVirtualIO = 0x02 //9bytes
    
}
enum IOTypeID: UInt16 {
    case motor = 0x0001
    case systemTrainMotor = 0x0002
    case button = 0x0005
    case ledLight = 0x0008
    case voltage = 0x0014
    case current = 0x0015
    case piezoTone = 0x0016
    case rgbLight = 0x0017
    case externalTiltSensor = 0x0022
    case motionSensor = 0x0023
    case visionSensor = 0x0025
    case externalMotorwithTacho = 0x0026
    case internalMotorwithTacho = 0x0027
    case internalTilt = 0x0028
    case trainBaseMotor = 0x29
    case trainBaseSpeaker = 0x2a
    case trainBaseColorSensor = 0x2b
    case trainBaseSpeedometer = 0x2c
    case largeMotor = 0x2e
    case extraLargeMotor = 0x2f
    case mediumAngularMotor = 0x30
    case largeAngularMotor = 0x31
    case technicMediumHubGestSensor = 0x36 // 54
    case powerControlButton = 0x37 // 55
    case remoteControlRSSI = 0x38 // 56
    case technicMediumHubAccelerometer = 0x39 // 57
    case technicMediumHubGyroSensor = 0x3a // 58
    case technicMediumHubTiltSensor = 0x3b // 59
    case technicMediumHubTemperatureSensor = 0x3c // 60
    case colorSensor = 0x3d
    case distanceSensor = 0x3e
    case forceSensor = 0x3f
    case colorLightMatrix = 0x40
    case smallAngularMotor = 0x41
    case marioAccelerometer = 0x47
    case marioColorBarcodeSensor = 0x49
    case marioPantsSensor = 0x4a
    case mediumAngularMotorGray = 0x4b
    case largeAngularMotorGray = 0x4c
}
struct HubAttachedIO: InputMessage {
    
    let messageType = MessageType.hubAttachedIO
    
    let port: Port
    let event: AttachedEvent
    let ioType: IOTypeID? //only virtual and attached
    let hardwareRevision: Int32? //only attached
    let softwareRevision: Int32? //only attached
    let portA: Port? //only virtual
    let portB: Port? //only virtual
    
    static func create(with reader: BytesReader) -> HubAttachedIO? {
        let port = reader.readPort()
        guard let event = AttachedEvent(rawValue: reader.readUInt8()) else {
            return nil
        }
        switch event {
        case .detachedIO:
            return HubAttachedIO(port: port,
                                 event: event,
                                 ioType: nil,
                                 hardwareRevision: nil,
                                 softwareRevision: nil,
                                 portA: nil,
                                 portB: nil)
        case .attachedIO:
            let val = reader.readUInt16()
            guard let ioType = IOTypeID(rawValue: val) else {
                print("UNKNOWN IOType \(val)")
                return nil
            }
            return HubAttachedIO(port: port,
                                 event: event,
                                 ioType: ioType,
                                 hardwareRevision: reader.readInt32(),
                                 softwareRevision: reader.readInt32(),
                                 portA: nil,
                                 portB: nil)
        case .attachedVirtualIO:
            let val = reader.readUInt16()
            guard let ioType = IOTypeID(rawValue: val) else {
                print("UNKNOWN IOType \(val)")
                return nil
            }
            let portA = reader.readPort()
            let portB = reader.readPort()
            return HubAttachedIO(port: port,
                                 event: event,
                                 ioType: ioType,
                                 hardwareRevision: nil,
                                 softwareRevision: nil,
                                 portA: portA,
                                 portB: portB)
        }
    }
}
