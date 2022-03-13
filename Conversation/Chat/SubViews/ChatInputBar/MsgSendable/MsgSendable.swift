//
//  MsgSendable.swift
//  Conversation
//
//  Created by Aung Ko Min on 14/2/22.
//

import SwiftUI
protocol MsgSendable {
    var inputManager: ChatInputViewManager { get }
    var coordinator: Coordinator { get }
}

extension MsgSendable {
    func resetView() {
        inputManager.currentInputItem = .Text
    }

    func send(msg: Msg) {
        coordinator.addNewMsg(msg: msg)
        OutgoingSocket.shared.saveAndSend(msg: msg)
    }
}
