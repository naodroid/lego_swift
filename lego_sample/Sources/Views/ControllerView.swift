//
//  ControllerView.swift
//  lego_sample
//
//  Created by nao on 2024/04/21.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct ControllerView: View {
    @Binding var paths: [Path]
    @State var carController: CarController
    @State var speed = 0
    
    init(paths: Binding<[Path]>,
         target: CBPeripheral,
         centralController: CentralController) {
        let ctrl = CarController(target: target, centralController: centralController)
        self._paths = paths
        self._carController = State(initialValue: ctrl)
    }
    var body: some View {
        VStack {
            if carController.deviceStatus.isReady {
                controlView
            } else {
                Text("Connecting...")
            }
        }
        .onAppear {
            carController.connect()
        }
        .onDisappear {
            carController.disconnect()
        }
    }
    @ViewBuilder
    var controlView: some View {
        Button {
            speed += 10
            carController.setFrontPower(power: speed)
            carController.setRearPower(power: speed)
        } label: {
            Text("UP")
        }
        Text("\(speed)")
        Button {
            speed -= 10
            carController.setFrontPower(power: speed)
            carController.setRearPower(power: speed)
        } label: {
            Text("DOWN")
        }
    }
}
