//
//  SpeedGraph.swift
//  lego_sample
//
//  Created by nao on 2024/04/29.
//

import Foundation
import SwiftUI
import Charts

struct SpeedGraph: View {
    let data: [SpeedData]
    var xMin: Int { xMax - 5 * 1000 } //second
    var xMax: Int { data.last?.time ?? 0}

    var body: some View {
        
        Chart(data) { d in
            LineMark(
                x: .value("TIME", d.time),
                y: .value("SPD", d.speed)
            )
        }
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine().foregroundStyle(.gray)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine().foregroundStyle(.gray)
            }
        }
        .chartXScale(domain: xMin...xMax)
        .chartYScale(domain: -100...100)
    }
}

