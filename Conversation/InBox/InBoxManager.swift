//
//  InBoxManager.swift
//  Conversation
//
//  Created by Aung Ko Min on 27/2/22.
//

import Foundation
import SwiftUI

class InBoxManager: ObservableObject {
    
    @Published var conversations = [Conversation]()
    
    func task() {
        conversations = CCon.cons().map(Conversation.init).sorted{ $0.lastMsg()?.date ?? Date() > $1.lastMsg()?.date ?? Date() }
    }
    
    func refresh() {
        conversations = CCon.cons().map(Conversation.init)
    }
}
