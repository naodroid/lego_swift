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
    @Environment(\.dismiss) var dismiss
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
            if carController.carStatus == .ready {
                TwoStickView()
            } else {
                Text("Connecting...")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    carController.powerOff()
                    dismiss()
                } label: {
                    Text("Shutdown").foregroundStyle(.red)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Control")
        .onAppear {
            carController.connect()
        }
        .onDisappear {
            carController.disconnect()
        }
        .environment(carController)
    }
}
struct TwoStickView: View {
    @Environment(CarController.self) var carController
    
    var body: some View {
        var braking = false
        var lastSpeed = 0
        
        HStack {
            Spacer()
            HStickView { v in
                carController.setAngle(v)
            }
            Spacer().frame(width: 40)
            VStickView { v in
                carController.setPower(-v)
            }
            Spacer()
        }
    }
}
