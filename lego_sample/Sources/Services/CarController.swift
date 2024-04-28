//
//  CarController.swift
//  lego_sample
//
//  Created by nao on 2024/04/21.
//

import Foundation
import SwiftUI
import CoreBluetooth


@Observable
class CarController: NSObject {
    let hubController: HubController
    
    private(set) var deviceStatus: DeviceStatus = .disconnected
    private(set) var speed: Float = 0
    private(set) var angle: Float = 0
    
    @ObservationIgnored private var stateObserver: NSKeyValueObservation?
    @ObservationIgnored private var characteristic: CBCharacteristic?
    @ObservationIgnored private var attachedDevices: [Port: HubAttachedIO] = [:]
    
    // MARk: initializer
    init(target: CBPeripheral, centralController: CentralController) {
        self.hubController = HubController(target: target,
                                           centralController: centralController)
        super.init()
        hubController.hubDelegate = self
    }
    
    func connect() {
        hubController.connect()
    }
    func disconnect() {
        hubController.disconnect()
    }
    // MARK: Sending
    func setPower(_ power: Int) {
        setFrontPower(power)
        setRearPower(power)
    }
    func setFrontPower(_ power: Int) {
        let v = max(min(power, 100), -100)
        let msg = MotorPower(port: .a, power: Int8(v))
        hubController.send(message: msg)
    }
    func setRearPower(_ power: Int) {
        let v = max(min(power, 100), -100)
        let msg = MotorPower(port: .b, power: Int8(v))
        hubController.send(message: msg)
    }
    func brake() {
        let front = MotorPower(port: .a, forBrake: ())
        let rear = MotorPower(port: .b, forBrake: ())
        hubController.send(message: front)
        hubController.send(message: rear)
    }
    
    func setAngle(_ angle: Int) {
        let msg = MotorAngle(port: .d, angle: Int32(angle))
        hubController.send(message: msg)
    }
}
// MARK: CBPeripheralDelegate
extension CarController: HubDelegate {
    func onDeviceStateChanged(_ status: DeviceStatus) {
        self.deviceStatus = status
    }
    func onHubAttachedIOReceived(_ msg: Message) {
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
                hubController.send(message: msg)
            case Port.d:
                //front steer motor
                let msg = PortInformationFormatSetup(
                    port: msg.port,
                    sensorMode: SensorMode.LargeMotor.absolutePosition.rawValue,
                    deltaInterval: 1000,
                    enabled: true)
                hubController.send(message: msg)
            default:
                print("UNKNOWN PORT")
            }
        }
    }
}
