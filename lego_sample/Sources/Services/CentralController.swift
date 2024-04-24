//
//  AudiCarService.swift
//  lego_sample
//
//  Created by nao on 2024/04/21.
//

import Foundation
import CoreBluetooth

public struct ScanResult: Identifiable, Equatable, Hashable {
    public let id: String
    public let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.id = peripheral.identifier.uuidString
        self.peripheral = peripheral
    }
}

public enum CentralError: Error {
    case alreadyConnecting
    case unknownError
}

@Observable
public class CentralController: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager?
    
    public private(set) var isScanning = false
    public private(set) var scanResults: [ScanResult] = []
    
    @ObservationIgnored private var connectingContinuation: CheckedContinuation<Void, Error>?
    @ObservationIgnored private var disconnectingContinuation: CheckedContinuation<Void, Error>?

    // MARK: initializer
    public override init() {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    // MARK: Scan
    public func scan() {
        if isScanning {
            return
        }
        isScanning = true
        _scanInner()
    }
    private func _scanInner() {
        guard let manager else {
            return
        }
        if manager.state == .poweredOn {
            manager.scanForPeripherals(withServices: [CBUUID(string: LegoGatt.serviceUUID)])
        }
    }
    public func stopScan() {
        manager?.stopScan()
        isScanning = false
    }
    
    // connect
    public func connect(peripheral: CBPeripheral) async throws {
        guard let manager else {
            return
        }
        if peripheral.state == .connected || peripheral.state == .connecting {
            return
        }
        try await withCheckedThrowingContinuation { continuation in
            self.connectingContinuation = continuation
            manager.connect(peripheral)
        }
    }
    public func disconnect(peripheral: CBPeripheral) async throws {
        guard let manager else {
            return
        }
        if peripheral.state == .disconnected {
            return
        }
        try await withCheckedThrowingContinuation { continuation in
            self.disconnectingContinuation = continuation
            manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: Central Delegate Impl
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            if isScanning {
                _scanInner()
            }
        case .poweredOff, .resetting, .unauthorized, .unknown, .unsupported:
            break
        @unknown default:
            break
        }
    }
    public func centralManager(_ central: CBCentralManager, 
                               didDiscover peripheral: CBPeripheral,
                               advertisementData: [String : Any],
                               rssi RSSI: NSNumber) {
        let result = ScanResult(peripheral: peripheral)
        let matchedIndex = scanResults.firstIndex { $0.id == peripheral.identifier.uuidString }
        if let matchedIndex {
            scanResults[matchedIndex] = result
            return
        }
        scanResults.append(result)
    }
    
    public func centralManager(_ central: CBCentralManager, 
                               didConnect peripheral: CBPeripheral) {
        connectingContinuation?.resume()
        connectingContinuation = nil
    }
    public func centralManager(_ central: CBCentralManager, 
                               didFailToConnect peripheral: CBPeripheral,
                               error: Error?) {
        let e = error ?? CentralError.unknownError
        connectingContinuation?.resume(throwing: e)
        connectingContinuation = nil
    }
    public func centralManager(_ central: CBCentralManager, 
                               didDisconnectPeripheral peripheral: CBPeripheral,
                               error: Error?) {
        if let error {
            disconnectingContinuation?.resume(throwing: error)
        } else {
            disconnectingContinuation?.resume()
        }
        disconnectingContinuation = nil
    }
}
