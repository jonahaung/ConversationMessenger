//
//  ImputTextViewManager.swift
//  Conversation
//
//  Created by Aung Ko Min on 30/1/22.
//

import SwiftUI


class ChatInputViewManager: ObservableObject {
    
    var text = String() {
        willSet {
            guard newValue.isEmpty || text.isEmpty else { return }
            objectWillChange.send()
        }
    }
    
    var hasText: Bool { !text.isEmpty }
    @Published var textViewHeight = CGFloat.zero
   
    @Published var currentInputItem = InputMenuBar.Item.Text

    deinit {
        Log("")
    }
}
