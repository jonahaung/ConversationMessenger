//
//  InBoxCell.swift
//  Conversation
//
//  Created by Aung Ko Min on 27/2/22.
//

import SwiftUI

import SwiftUI

struct InBoxCell: View {
    
    @EnvironmentObject private var conversation: Conversation
    
    var body: some View {
        Group {
            
            AvatarView(id: conversation.id)
                .frame(width: 45, height: 45)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(conversation.name)
                        .font(.headline)
                    +
                    Text(" \(conversation.msgsCount()) ")
                        .italic()
                        .font(.caption2)
                    
                    Group {
                        if let msg = self.conversation.lastMsg() {
                            Spacer()
                            let dateText = MsgDateView.relativeDateFormatter.string(for: msg.date) ?? ""
                            Text(dateText + " ")
                                .font(.footnote)
                            +
                            Text(msg.deliveryStatus.description)
                                .font(.caption)
                                .underline()
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                
                Group {
                    if let msg = self.conversation.lastMsg() {
                        Group {
                            Text(msg.rType == .Send ? "You  " : "Jonah  ")
                                .fontWeight(.semibold)
                                .italic()
                            +
                            Text(msg.textData?.text ?? "\(msg.msgType)")
                        }
                        .font(.body)
                        .lineLimit(3)
                        .foregroundStyle(progressStyle(for: msg))
                    }
                }
            }
        }
        .tapToPush(
            ChatView(conversation)
                .navigationBarHidden(true)
        )
    }
    
    private func progressStyle(for msg: Msg) -> some ShapeStyle {
        if msg.rType == .Send {
            return .secondary
        }
        return (msg.deliveryStatus == .Read ? .secondary : .primary)
    }
}
