//
//  IncomingSocket.swift
//  Conversation
//
//  Created by Aung Ko Min on 9/2/22.
//

import UIKit


class IncomingSocket {
    
    static let shard = IncomingSocket()
    
    private init() {}
    
    private let queue: OperationQueue = {
        $0.name = "Socket"
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    private var conversation: Conversation?
    
    func connect(with conversation: Conversation) {
        disconnect()
        self.conversation = conversation
    }
    
    func disconnect() {
        conversation = nil
        queue.cancelAllOperations()
        Log("Disconnected")
    }
    
    func random() {
        queue.addOperation {
            self.generateRandomMsg()
        }
    }
    
    func generateRandomMsg() {
        guard let conId = conversation?.id else { return }
        guard AppUserDefault.shared.autoGenerateMockMessages else { return }
        setTyping(isTyping: true)
        Thread.sleep(forTimeInterval: TimeInterval(Int.random(in: 1...3)))
        setTyping(isTyping: false)
        Thread.sleep(forTimeInterval: TimeInterval(Int.random(in: 1...3)))
        let msg = createRandomMsg(conId: conId)
        showMsg(msg: msg)
    }
    
    func sendHasRead(id: String) {
        guard let conId = conversation?.id else { return }

        if let cCon = CCon.cCon(for: conId), let cMsg = CMsg.msg(for: id) {
            cCon.lastReadMsgId = id
            cMsg.progress = Msg.DeliveryStatus.Read.rawValue
            sendUpdate(id: id)
        }
    }
    private func createRandomMsg(conId: String) -> Msg {
        let msg = Msg(conId: conId, msgType: .Text, rType: .Receive, progress: .Read)
        let text = [Lorem.sentence, Lorem.shortTweet, Lorem.tweet, Lorem.fullName, Lorem.title].random() ?? Lorem.emailAddress
        msg.textData = .init(text: text)
        saveAtCoredata(msg: msg)
        return msg
    }
    private func saveAtCoredata(msg: Msg) {
        CMsg.create(msg: msg)
        let op = MsgReceiverOperation(msg)
        queue.addOperation(op)
    }
    
    private func showMsg(msg: Msg) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .MsgNoti, object: MsgNoti(type: .New(msg: msg)))
        }
    }
    
    private func setTyping(isTyping: Bool ) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .MsgNoti, object: MsgNoti(type: .Typing(isTyping: isTyping)))
        }
    }
    
    private func sendUpdate(id: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .MsgNoti, object: MsgNoti(type: .Update(id: id)))
        }
    }
    deinit {
        Log("")
    }
}

