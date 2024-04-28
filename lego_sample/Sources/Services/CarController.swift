//
//  CarController.swift
//  lego_sample
//
//  Created by nao on 2024/04/21.
//

import Foundation
import SwiftUI
import CoreBluetooth


enum DeviceStatus: Equatable {
    case disconnected
    case connecting
    case discoveringServices
    case discoveringCharacteristic(service: CBService)
    case ready(service: CBService, charateristic: CBCharacteristic)
    
    var service: CBService? {
        switch self {
        case .discoveringCharacteristic(let service):
            return service
        case .ready(let service, _):
            return service
        default:
            return nil
        }
    }
    var characteristic: CBCharacteristic? {
        switch self {
        case .ready(_, let charateristic):
            return charateristic
        default:
            return nil
        }
    }
    var isReady: Bool { characteristic != nil }
}


@Observable
class CarController: NSObject {
    let target: CBPeripheral
    weak var centralController: CentralController?
    
    private(set) var deviceStatus: DeviceStatus = .disconnected
    private(set) var speed: Float = 0
    private(set) var angle: Float = 0
    
    @ObservationIgnored private var stateObserver: NSKeyValueObservation?
    @ObservationIgnored private var characteristic: CBCharacteristic?
    @ObservationIgnored private var attachedDevices: [Port: HubAttachedIO] = [:]
    
    // MARk: initializer
    init(target: CBPeripheral, centralController: CentralController) {
        self.target = target
        self.centralController = centralController
        super.init()
        target.delegate = self
        
        self.stateObserver = target.observe(\.state) {[weak self] p, _ in
            guard let self else {
                return
            }
            switch p.state {
            case .connected:
                self.onConnected()
            case .connecting:
                break
            case .disconnecting:
                break
            case .disconnected:
                self.onDisconnected()
            @unknown default:
                break
            }
        }
    }
    
    func connect() {
        Task {
            do {
                self.onStartedConnection()
                try await centralController?.connect(peripheral: target)
            } catch {
                print("FAILED TO CONNECT: \(error)")
            }
        }
    }
    func disconnect() {
        Task {
            do {
                //power off the hub
                send(message: HubActionMessage(actionType: .switchOffHub))
                //wait until completed sending
                //TODO: use delegate to detect compeltion
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                try await centralController?.disconnect(peripheral: target)
            } catch {
                print("FAILED TO DISCONNECT: \(error)")
            }
        }
    }
    // MARK: Sending
    func send(message: OutputMessage, requireResponse: Bool = false) {
        guard let ch = self.deviceStatus.characteristic else {
            print("DEVICE NOT READY")
            return
        }
        let data = Encoder.encode(message: message)
        target.writeValue(data, for: ch, type: requireResponse ? .withResponse : .withoutResponse)
    }
    func setPower(_ power: Int) {
        setFrontPower(power)
        setRearPower(power)
    }
    func setFrontPower(_ power: Int) {
        let v = max(min(power, 100), -100)
        let msg = MotorPower(port: .a, power: Int8(v))
        send(message: msg)
    }
    func setRearPower(_ power: Int) {
        let v = max(min(power, 100), -100)
        let msg = MotorPower(port: .b, power: Int8(v))
        send(message: msg)
    }
    func brake() {
        let front = MotorPower(port: .a, forBrake: ())
        let rear = MotorPower(port: .b, forBrake: ())
        send(message: front)
        send(message: rear)
    }
    
    func setAngle(_ angle: Int) {
        let msg = MotorAngle(port: .d, angle: Int32(angle))
        send(message: msg)
    }
    
    
    // MARK: State Managment
    private func onStartedConnection() {
        self.deviceStatus = .connecting
    }
    private func onConnected() {
        self.deviceStatus = .discoveringServices
        let uuid = CBUUID(string: LegoGatt.serviceUUID)
        target.discoverServices([uuid])
    }
    private func onFoundService(_ service: CBService) {
        self.deviceStatus = .discoveringCharacteristic(service: service)
        let uuid = CBUUID(string: LegoGatt.characteristicUUID)
        target.discoverCharacteristics([uuid], for: service)
    }
    private func onFoundCharacteristic(service: CBService, characteristic: CBCharacteristic) {
        self.deviceStatus = .ready(service: service, charateristic: characteristic)
        target.setNotifyValue(true, for: characteristic)
    }
    
    private func onDisconnected() {
        self.deviceStatus = .disconnected
    }
}
// MARK: CBPeripheralDelegate
extension CarController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard let data = characteristic.value else {
            return
        }
        if let msg = Decoder.decode(data) {
            onMessageReceived(msg)
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first else {
            print("ERROR")
            return
        }
        self.onFoundService(service)
    }
    func peripheral(_ peripheral: CBPeripheral, 
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristic = service.characteristics?.first else {
            print("ERROR")
            return
        }
        self.onFoundCharacteristic(service: service, characteristic: characteristic)
    }
}
extension CarController {
    private func onMessageReceived(_ msg: Message) {
        print("MSG:\(msg.messageType)")
        switch msg.messageType {
        case .hubAttachedIO:
            onHubAttachedIOReceived(msg)
        case .genericErrorMessages:
            print("ERROR!\(msg)")
        case .hubProperties, .hubActions, .hubAlerts:
            break
        case .hwNetWorkCommands, .fwUpdateGoIntoBooMode:
            break
        case .fwUpdateLockMemory, .fwUpdateLockStatusRequest, .fwLockStatus:
            break
        case .portInformationRequest, .portModeInformationRequest:
            break
        case .portInputFormatSetupSingle, .portInputFormatSetupCombinedMode:
            break
        case .portInformation, .portModeInformation:
            break
        case .portValueSingle:
            break
        case .portValueCombinedMode:
            break
        case .portInputFormatSingle, .portInputFormatCombinedMode:
            break
        case .virtualPortSetup, .portOutputCommand, .portOutputCommandFeedback:
            break
        }

    }
    private func onHubAttachedIOReceived(_ msg: Message) {
        guard let msg = msg as? HubAttachedIO else {
            return
        }
        switch msg.event {
        case .detachedIO:
            attachedDevices[msg.port] = nil
        case .attachedIO, .attachedVirtualIO:
            attachedDevices[msg.port] = msg
            switch msg.port {
            case Port.a, Port.b:
                //front & rear power motor
                let msg = PortInformationFormatSetup(
                    port: msg.port,
                    sensorMode: SensorMode.LargeMotor.speed.rawValue,
                    deltaInterval: 1000,
                    enabled: false)
                send(message: msg)
            case Port.d:
                //front steer motor
                let msg = PortInformationFormatSetup(
                    port: msg.port,
                    sensorMode: SensorMode.LargeMotor.absolutePosition.rawValue,
                    deltaInterval: 1000,
                    enabled: true)
                send(message: msg)
            default:
                print("UNKNOWN PORT")
            }
        }
    }
}
