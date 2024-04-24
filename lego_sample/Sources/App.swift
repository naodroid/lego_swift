//
//  lego_sampleApp.swift
//  lego_sample
//
//  Created by nao on 2024/04/21.
//

import SwiftUI

@main
struct LegoSampleApp: App {
    @State var carService = CentralController()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(carService)
    }
}
