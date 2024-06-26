//
//  CarController.swift
//  lego_sample
//
//  Created by nao on 2024/04/21.
//

import Foundation
import SwiftUI
import CoreBluetooth


enum CarStatus: Equatable {
    case disconnected
    case connecting
    case initializing(portA: Bool, portB: Bool, portD: Bool)
    case calibrating
    case ready
}
struct SpeedData: Identifiable {
    var id: Int
    var time: Int //timeinterval * 1000
    var speed: Int
    init(time: TimeInterval, speed: Int) {
        self.id = Int(time * 1000)
        self.time = self.id
        self.speed = speed
    }
}


private func createInitialData() -> [SpeedData] {
    let count = TimeInterval(CarController.keepDurationInMSec) / 30
    let delta = TimeInterval(CarController.keepDurationInMSec) / count
    let current = CACurrentMediaTime()
    var time = current - TimeInterval(CarController.keepDurationInMSec)
    var ret: [SpeedData] = []
    while time < current {
        ret.append(SpeedData(time: time, speed: 0))
        time += 0.1
    }
    return ret
}

@Observable
class CarController: NSObject {
    let hubController: HubController
    static let keepDurationInMSec = 5 * 1000
    
    private(set) var speedHistories: [SpeedData] = createInitialData()
    private(set) var angle: Int = 0
    private(set) var carStatus: CarStatus = .disconnected
    
    @ObservationIgnored private var stateObserver: NSKeyValueObservation?
    @ObservationIgnored private var characteristic: CBCharacteristic?
    @ObservationIgnored private var attachedDevices: [Port: HubAttachedIO] = [:]
    @ObservationIgnored private var steeringRange: ClosedRange<Int> = 0...0
    
    
    
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
    func powerOff() {
        hubController.powerOff()
    }
    // MARK: Sending
    func setPower(_ power: Int) {
        let v = power.clamped(to: -100...100)
        let front = MotorPower(port: .a, power: Int8(v))
        let rear = MotorPower(port: .b, power: Int8(v))
        hubController.send(message: front)
        hubController.send(message: rear)
    }
    func brake() {
        let front = MotorPower(port: .a, forBrake: ())
        let rear = MotorPower(port: .b, forBrake: ())
        hubController.send(message: front)
        hubController.send(message: rear)
    }
    func setSpeed(_ speed: Int) {
        let v = speed.clamped(to: -100...100)
        let front = MotorSpeed(port: .a, speed: Int8(v))
        let rear = MotorSpeed(port: .b, speed: Int8(v))
        hubController.send(message: front)
        hubController.send(message: rear)
    }
    
    func setAngle(_ angle: Int) {
        var value = angle
        let diff = (steeringRange.upperBound - steeringRange.lowerBound) / 2
        let center = (steeringRange.upperBound + steeringRange.lowerBound) / 2
        if diff > 0 {
            value = diff * angle / 100 + center
        }
        let msg = MotorAngle(port: .d, angle: Int32(value))
        hubController.send(message: msg)
    }
}
// MARK: CBPeripheralDelegate
extension CarController: HubDelegate {
    func onDeviceStateChanged(_ status: DeviceStatus) {
        switch status {
        case .connecting:
            self.carStatus = .connecting
        case .disconnected:
            self.carStatus = .disconnected
        case .ready, .discoveringServices, .discoveringCharacteristic:
            break
        }
    }
    func onHubAttachedIOReceived(_ msg: HubAttachedIO) {
        switch msg.event {
        case .detachedIO:
            attachedDevices[msg.port] = nil
        case .attachedIO, .attachedVirtualIO:
            attachedDevices[msg.port] = msg
            switch msg.port {
            case Port.a, Port.b:
                //set front as notification enabled for speed
                let msg = PortInformationFormatSetup(
                    port: msg.port,
                    sensorMode: SensorMode.LargeMotor.speed.rawValue,
                    deltaInterval: 0,
                    enabled: msg.port == Port.a)
                hubController.send(message: msg)
            case Port.d:
                //front steer motor
                let msg = PortInformationFormatSetup(
                    port: msg.port,
                    sensorMode: SensorMode.LargeMotor.position.rawValue,
                    deltaInterval: 0, //it seems that this time doesn't work
                    enabled: true)
                hubController.send(message: msg)
            default:
                print("UNKNOWN PORT")
                return
            }
            let isA = msg.port == Port.a
            let isB = msg.port == Port.b
            let isD = msg.port == Port.d
            switch carStatus {
            case .connecting:
                carStatus = .initializing(portA: isA, portB: isB, portD: isD)
            case .initializing(let portA, let portB, let portD):
                let flagA = isA || portA
                let flagB = isB || portB
                let flagD = isD || portD
                if flagA && flagB && flagD {
                    carStatus = .calibrating
                    calibrate()
                } else {
                    carStatus = .initializing(portA: isA || portA,
                                              portB: isB || portB,
                                              portD: isD || portD)
                }
            default:
                return
            }
        }
    }
    func onPortValueReceived(_ msg: PortValueSingle) {
        switch msg.port {
        case .a:
            let spd = BytesReader(bytes: msg.value).readInt8()
            let data = SpeedData(time: CACurrentMediaTime(), speed: Int(spd))
            var graph = speedHistories
            graph.append(data)
            graph = graph.filter { $0.time >= data.time - CarController.keepDurationInMSec }
            self.speedHistories = graph
        case .d:
            let angle = BytesReader(bytes: msg.value).readInt32()
            self.angle = Int(angle)
        default:
            break
        }
    }
    func calibrate() {
        guard case .calibrating = carStatus else {
            return
        }
        Task {
            let waitNSec: UInt64 = 500_000_000
            setAngle(self.angle - 300)
            try? await Task.sleep(nanoseconds: waitNSec)
            //In my lego-car, the steering offset to left a little
            let left = self.angle - 2
            setAngle(left + 300)
            try? await Task.sleep(nanoseconds: waitNSec)
            let right = self.angle + 2
            let center = (left + right) / 2
            setAngle(center)
            try? await Task.sleep(nanoseconds: waitNSec / 2)
            self.steeringRange = left...right
            print(left)
            print(right)
            self.carStatus = .ready
            self.speedHistories = createInitialData()
        }
    }
}
