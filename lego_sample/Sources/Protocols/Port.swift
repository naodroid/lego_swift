//
//  Port.swift
//  bt_sample
//
//  Created by 坂本　尚嗣 on 2024/04/16.
//

import Foundation

struct Port: Equatable, Hashable {
    let id: UInt8
    var isHubConnector: Bool {
        id >= 0 && id <= 49
    }
    var isInternal: Bool {
        id >= 50 && id <= 100
    }
    
    static let a = Port(id: 0)
    static let b = Port(id: 1)
    static let c = Port(id: 2)
    static let d = Port(id: 3)
}
