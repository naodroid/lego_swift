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
        HStack {
            if carController.deviceStatus.isReady {
                Spacer()
                SteerView()
                Spacer()
                PowerView()
                Spacer()
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
        .environment(carController)
    }
}

struct PowerView: View {
    @Environment(CarController.self) var carController
    @State var power = 0
    
    var body: some View {
        VStack {
            Button {
                power += 10
                carController.setPower(power)
            } label: {
                Text("UP")
            }
            Text("\(power)")
            Button {
                power -= 10
                carController.setPower(power)
            } label: {
                Text("DOWN")
            }
            Spacer().frame(height: 8)
            Button {
                power = 0
                carController.setPower(power)
            } label: {
                Text("BRAKE")
            }
        }.font(.title)
    }
}
struct SteerView: View {
    @Environment(CarController.self) var carController
    @State var steer = 0
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    steer += 10
                    carController.setAngle(steer)
                } label: {
                    Text("L")
                }
                Button {
                    steer -= 10
                    carController.setAngle(steer)
                } label: {
                    Text("R")
                }
            }
            Text("\(steer)")
            Button {
                steer = 0
                carController.setAngle(steer)
            } label: {
                Text("CENTER")
            }
        }.font(.title)
    }
}
