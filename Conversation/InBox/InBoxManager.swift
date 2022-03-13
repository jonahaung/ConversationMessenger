//
//  InBoxManager.swift
//  Conversation
//
//  Created by Aung Ko Min on 27/2/22.
//

import Foundation
import SwiftUI

class InBoxManager: ObservableObject {
    @Published var conversations: LazyList<Conversation>
    private var hasLoaded = false
    init() {
        let cCons = CCon.cons()
        conversations = .init(count: cCons.count, useCache: false) { Conversation(cCon: cCons[$0]) }
    }
    
    func task() {
        if hasLoaded {
            withAnimation(.interactiveSpring()) {
                objectWillChange.send()
            }
        } else {
            hasLoaded = true
        }
        
    }
    
    func refresh() {
        objectWillChange.send()
//        self.cons = CCon.cons().map(Conversation.init)
    }
}
