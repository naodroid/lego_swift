//
//  HubController.swift
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

protocol HubDelegate: AnyObject {
    func onDeviceStateChanged(_ status: DeviceStatus)
    func onPortValueReceived(_ msg: PortValueSingle)
    func onHubAttachedIOReceived(_ msg: HubAttachedIO)
}

class HubController: NSObject {
    let target: CBPeripheral
    weak var centralController: CentralController?
    weak var hubDelegate: HubDelegate?
    
    private(set) var deviceStatus: DeviceStatus = .disconnected {
        didSet {
            self.hubDelegate?.onDeviceStateChanged(deviceStatus)
        }
    }
    private var stateObserver: NSKeyValueObservation?
    private var characteristic: CBCharacteristic?
    private var attachedDevices: [Port: HubAttachedIO] = [:]
    
    // MARk: initializer
    init(target: CBPeripheral, 
         centralController: CentralController) {
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
                send(message: HubActionMessage(actionType: .disconnect))
                //wait until completed sending
                //TODO: use delegate to detect compeltion
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                try await centralController?.disconnect(peripheral: target)
            } catch {
                print("FAILED TO DISCONNECT: \(error)")
            }
        }
    }
    func powerOff() {
        Task {
            do {
                //power off the hub
                send(message: HubActionMessage(actionType: .shutdown))
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                //wait until completed sending
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
extension HubController: CBPeripheralDelegate {
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
extension HubController {
    private func onMessageReceived(_ msg: Message) {
        print("MSG:\(msg.messageType)")
        switch msg.messageType {
        case .hubAttachedIO:
            let m = msg as! HubAttachedIO
            self.hubDelegate?.onHubAttachedIOReceived(m)
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
            print("VAL:PORT")
            let value = msg as! PortValueSingle
            hubDelegate?.onPortValueReceived(value)
        case .portValueCombinedMode:
            break
        case .portInputFormatSingle, .portInputFormatCombinedMode:
            break
        case .virtualPortSetup, .portOutputCommand, .portOutputCommandFeedback:
            break
        }
    }
}

