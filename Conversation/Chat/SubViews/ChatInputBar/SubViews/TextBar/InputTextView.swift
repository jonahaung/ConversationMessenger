//
//  InputTextView.swift
//  Conversation
//
//  Created by Aung Ko Min on 30/1/22.
//

import SwiftUI

struct InputTextView: UIViewRepresentable {
    
    @EnvironmentObject private var inputManager: ChatInputViewManager
    @EnvironmentObject private var coordinator: Coordinator
    
    func makeUIView(context: Context) -> GrowingTextView {
        let textView = GrowingTextView()
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: GrowingTextView, context: Context) {
        guard uiView.text != inputManager.text else { return }
        uiView.text = inputManager.text
    }
    
    func makeCoordinator() -> TextViewCoordinator {
        TextViewCoordinator(self)
    }
    
    class TextViewCoordinator: NSObject, GrowingTextViewDelegate {
        
        private let parent: InputTextView
        
        init(_ parent: InputTextView) {
            self.parent = parent
        }
        
        func growingTextViewDidChange(_ growingTextView: GrowingTextView) {
            parent.inputManager.text = growingTextView.text
        }
        
        func growingTextViewShouldBeginEditing(_ growingTextView: GrowingTextView) -> Bool {
            return parent.coordinator.layout.inputTextView(willUpdateFirstResponder: true)
        }
        func growingTextViewShouldEndEditing(_ growingTextView: GrowingTextView) -> Bool {
            return parent.coordinator.layout.inputTextView(willUpdateFirstResponder: false)
        }
        
        func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
            parent.inputManager.textViewHeight = height
            parent.coordinator.layout.inputTextView(textView: parent, didChangeTextViewHeight: difference)
        }
    }
}
