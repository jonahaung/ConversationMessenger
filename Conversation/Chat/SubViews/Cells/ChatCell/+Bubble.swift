//
//  +Bubble.swift
//  Conversation
//
//  Created by Aung Ko Min on 13/2/22.
//

import SwiftUI

extension ChatCell {
    
    internal func bubbleView() -> some View {
        Group {
            switch msg.msgType {
            case .Text:
                TextBubble(style: style)
            case .Image:
                ImageBubble()
            case .Location:
                LocationBubble()
            case .Emoji:
                if let data = msg.emojiData {
                    EmojiBubble(data: data)
                }
            default:
                EmptyView()
            }
        }
        .contextMenu{ MsgContextMenu().environmentObject(msg) }
        .onTapGesture {
            ToneManager.shared.vibrate(vibration: .rigid)
            withAnimation(.interactiveSpring()) {
                viewComponents.selectedId = msg.id == viewComponents.selectedId ? nil : msg.id
            }
        }
    }
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
