//
//  PortOutputCommandFeedback.swift
//  lego_sample
//
//  Created by nao on 2024/04/29.
//

import Foundation

enum FeedbackMessage: UInt8 {
    case bufferEmptyAndCommandInProgress = 0x01
    case bufferEmptyAndCommandCompleted = 0x02
    case currentCommandDiscarded = 0x04
    case idle = 0x08
    // Audi returns 0x0a, but I can't find what that is.
    case unknown = 0xa0
    case busyOrFull = 0x10
}
struct PortOutputCommandFeedback: InputMessage {
    let messageType = MessageType.portOutputCommandFeedback
    let port: Port
    let feedback: FeedbackMessage
    
    static func create(reader: BytesReader) -> PortOutputCommandFeedback? {
        let port = reader.readPort()
        let val = reader.readUInt8()
        guard let feedback = FeedbackMessage(rawValue: val) else {
            return nil
        }
        return PortOutputCommandFeedback(port: port, feedback: feedback)
    }
    
}
