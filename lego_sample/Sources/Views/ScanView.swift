//
//  ScanView.swift
//  lego_sample
//
//  Created by nao on 2024/04/21.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct ScanView: View {
    @Environment(CentralController.self) var controller
    @Binding var paths: [Path]
    
    var body: some View {
        VStack {
            List(controller.scanResults) { result in
                Button {
                    let path = Path.carCntrol(result: result)
                    paths.append(path)
                } label: {
                    Text(result.peripheral.name ?? "(null)")
                }
            }
        }
        .navigationTitle("Scanning")
        .onAppear {
            controller.scan()
        }
        .onDisappear {
            controller.stopScan()
        }
    }
}
