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
    
    public private(set) var deviceStatus: DeviceStatus = .disconnected
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
    func setupFormat() {
        let format = PortInformationFormatSetup(port: Port.a,
                                                deltaInterval: 100,
                                                enabled: true)
        send(message: format)
    }
    func setFrontPower(power: Int) {
        let v = max(min(power, 100), -100)
        let msg = MotorPower(power: Int8(v), port: .a)
        send(message: msg)
    }
    func setRearPower(power: Int) {
        let v = max(min(power, 100), -100)
        let msg = MotorPower(power: Int8(v), port: .b)
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
        print("SETUP_FORMAT")
        setupFormat()
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
            switch msg.messageType {
            case .hubProperties:
                break
            case .hubActions:
                break
            case .hubAlerts:
                break
            case .hubAttachedIO:
                onHubAttachedIOReceived(msg)
            case .genericErrorMessages:
                break
            case .hwNetWorkCommands:
                break
            case .fwUpdateGoIntoBooMode:
                break
            case .fwUpdateLockMemory:
                break
            case .fwUpdateLockStatusRequest:
                break
            case .fwLockStatus:
                break
            case .portInformationRequest:
                break
            case .portModeInformationRequest:
                break
            case .portInputFormatSetupSingle:
                break
            case .portInputFormatSetupCombinedMode:
                break
            case .portInformation:
                break
            case .portModeInformation:
                break
            case .portValueSingle:
                break
            case .portValueCombinedMode:
                break
            case .portInputFormatSingle:
                break
            case .portInputFormatCombinedMode:
                break
            case .virtualPortSetup:
                break
            case .portOutputCommand:
                break
            case .portOutputCommandFeedback:
                break
            }
        } else {
            print("FAILED TO PARSE:\(data)")
        }
    }
    
    
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("READY!")
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
    private func onHubAttachedIOReceived(_ msg: Message) {
        guard let msg = msg as? HubAttachedIO else {
            return
        }
        switch msg.event {
        case .detachedIO:
            attachedDevices[msg.port] = nil
        case .attachedIO, .attachedVirtualIO:
            attachedDevices[msg.port] = msg
        }
    }
}
