//
//  OutgoingSocket.swift
//  Conversation
//
//  Created by Aung Ko Min on 9/2/22.
//

import Foundation

class OutgoingSocket {
    
    static let shared = OutgoingSocket()
    
    private let queue: OperationQueue = {
        $0.name = "Socket"
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    private init() {}

    func saveAndSend(msg: Msg) {
        CMsg.create(msg: msg)
        let op = MsgSenderOperation(msg)
        queue.addOperation(op)
    }
}
