//
//  HStickView.swift
//  lego_sample
//
//  Created by nao on 2024/04/29.
//

import Foundation
import SwiftUI

struct HStickView: View {
    @State var touching = false
    @State var value = 0 {
        didSet {
            onChanged(value)
        }
    }
    let onChanged: (Int) -> Void
    
    
    var body: some View {
        let width: CGFloat = 180.0
        let height: CGFloat = 44.0
        let radius = height / 2
        let x = width / 2 + (width / 2 - radius) * CGFloat(value) / 100 - radius
        
        ZStack {
            SwiftUI.Path { path in
                path.addRoundedRect(
                    in: CGRect(x: 0, y: 0, width: width, height: height),
                    cornerSize: CGSizeMake(radius, radius)
                )
            }
            .fill(.thinMaterial)
            
            SwiftUI.Path { path in
                path.addRoundedRect(
                    in: CGRect(x: 0, y: 0, width: width, height: height),
                    cornerSize: CGSizeMake(radius, radius)
                )
            }
            .stroke(.primary)
            
            SwiftUI.Path { path in
                path.addEllipse(
                    in: CGRect(x: x + 2, y: 2, width: radius * 2 - 4, height: radius * 2 - 4)
                )
            }
            .fill(touching ? .red : .secondary)
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let w2 = width / 2
                    let dx = (gesture.location.x - w2) / w2
                    value = Int(dx * 100).clamped(to: -100...100)
                    touching = true
                }
                .onEnded { _ in
                    value = 0
                    touching = false
                }
        )
        .frame(
            width: width,
            height: height
        )
    }
}

