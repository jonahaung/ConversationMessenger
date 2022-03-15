//
//  TextBubble.swift
//  Conversation
//
//  Created by Aung Ko Min on 31/1/22.
//

import SwiftUI

struct TextBubble: View {
    
    let style: MsgStyle
    @EnvironmentObject internal var msg: Msg
    @EnvironmentObject internal var conversation: Conversation
    
    
    var body: some View {
        Group {
            if let data = msg.textData {
                Text(data.text)
                    .font(.body)
                    .padding(.horizontal, ChatKit.ChatCell.TextBubble.insets.width)
                    .padding(.vertical, ChatKit.ChatCell.TextBubble.insets.height)
                    .foregroundColor( msg.rType == .Send ? ChatKit.ChatCell.TextBubble.textColorOutgoing : ChatKit.ChatCell.TextBubble.textColorIncoming)
                    .background(conversation.bubbleColor(for: msg).clipShape(style.bubbleShape!))
            }
        }
    }
}
