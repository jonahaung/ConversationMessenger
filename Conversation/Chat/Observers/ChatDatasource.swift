//
//  MsgDatasource.swift
//  Conversation
//
//  Created by Aung Ko Min on 31/1/22.
//

import Foundation
import CoreMIDI

protocol ChatDatasourceDelegagte: AnyObject {
    var msgs: [Msg] { get }
    var hasMoreNext: Bool { get }
    var hasMorePrevious: Bool { get }
    @MainActor func loadNext()
    @MainActor func loadPrevious()
    @MainActor func update(id: String)
    @MainActor func msg(for id: String) -> Msg?
    @MainActor func add(msg: Msg)
    @MainActor func remove(msg: Msg)
}

class ChatDatasource: ObservableObject, ChatDatasourceDelegagte {
    
    private let slidingWindow: SlidingDataSource<Msg>
    private let pageSize: Int
    private let preferredMaxWindowSize: Int
    
    var msgs: [Msg] { slidingWindow.itemsInWindow }
    
    init(conId: String) {
        pageSize = AppUserDefault.shared.pagnitionSize
        preferredMaxWindowSize = pageSize * 3
        slidingWindow = SlidingDataSource(items: CMsg.msgs(for: conId).map(Msg.init), pageSize: pageSize)
    }
    
    var hasMoreNext: Bool {
        return slidingWindow.hasMore()
    }
    
    var hasMorePrevious: Bool {
        return slidingWindow.hasPrevious()
    }
    
    @MainActor func add(msg: Msg) {
        slidingWindow.insertItem(msg, position: .bottom)
        objectWillChange.send()
    }
    
    @MainActor func remove(msg: Msg) {
        if CMsg.delete(id: msg.id) {
            slidingWindow.remove(where: { $0.id == msg.id })
        }
    }
    
    func msg(for id: String) -> Msg? {
        slidingWindow.item(for: id)
    }
    
    @MainActor func update(id: String) {
        if let msg = slidingWindow.item(for: id), msg.update() {
            msg.updateUI()
        }
    }
    
    @MainActor
    func loadNext() {
        self.slidingWindow.loadNext()
        self.slidingWindow.adjustWindow(focusPosition: 1, maxWindowSize: self.preferredMaxWindowSize)
    }
    @MainActor
    func loadPrevious() {
        self.slidingWindow.loadPrevious()
        self.slidingWindow.adjustWindow(focusPosition: 0, maxWindowSize: self.preferredMaxWindowSize)
    }
    
    @MainActor
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double) -> Bool {
        return self.slidingWindow.adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? self.preferredMaxWindowSize)
    }
    
    deinit {
        Log("")
    }
}
