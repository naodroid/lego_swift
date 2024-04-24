//
//  ContentView.swift
//  lego_sample
//
//  Created by nao on 2024/04/21.
//

import SwiftUI

enum Path: Equatable, Hashable {
    case scan
    case carCntrol(result: ScanResult)
}


struct ContentView: View {
    @State var paths: [Path] = []
    @Environment(CentralController.self) var centralController
    
    var body: some View {
        NavigationStack(path: $paths) {
            ScanView(paths: $paths)
                .navigationDestination(for: Path.self) { path in
                    switch path {
                    case .scan:
                        ScanView(paths: $paths)
                    case .carCntrol(let result):
                        ControllerView(
                            paths: $paths,
                            target: result.peripheral,
                            centralController: centralController
                        )
                    }
                }
        }
        .environment(centralController)
    }
}

#Preview {
    ContentView()
}
