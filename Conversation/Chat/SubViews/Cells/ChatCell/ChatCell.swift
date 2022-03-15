//
//  MessageCell.swift
//  MyBike
//
//  Created by Aung Ko Min on 22/1/22.
//

import SwiftUI

struct ChatCell: View {
    
    @EnvironmentObject internal var msg: Msg
    @EnvironmentObject internal var conversation: Conversation
    @EnvironmentObject internal var viewComponents: ViewComponents
    let style: MsgStyle
    
    fileprivate func leftView() -> some View {
        Group {
            if msg.rType == .Send {
                Spacer(minLength: ChatKit.ChatCell.flexiableSpacing)
            } else {
                VStack {
                    if style.showAvatar {
                        AvatarView(id: conversation.id)
                    }
                }
                .frame(width: ChatKit.ChatCell.statusViewSize)
            }
        }
    }
    
    fileprivate func rightView() -> some View {
        Group {
            if msg.rType == .Receive {
                Spacer(minLength: ChatKit.ChatCell.flexiableSpacing)
                
            } else {
                VStack {
                    if style.showAvatar {
                        AvatarView(id: conversation.id)
                    }else {
                        CellProgressView(progress: msg.deliveryStatus)
                    }
                }
                .frame(width: ChatKit.ChatCell.statusViewSize)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if style.showTimeSeparater {
                TimeSeparaterCell(date: msg.date)
            }
            if style.showTopPadding {
                Spacer(minLength: 10)
            }
            HStack(alignment: .bottom, spacing: 2) {
                leftView()
                VStack(alignment: msg.rType.hAlignment, spacing: 2) {
                    if style.isSelected {
                        let text = msg.rType == .Send ? MsgDateView.dateFormatter.string(from: msg.date) : msg.sender.name
                        HiddenLabelView(text: text, padding: .top)
                    }
                    
                    Group {
                        if style.isSelected {
                            bubbleView()
                                .modifier(DraggableModifier(direction: .horizontal))
                        } else {
                            bubbleView()
                        }
                    }
                    
                    if style.isSelected {
                        HiddenLabelView(text: msg.deliveryStatus.description, padding: .bottom)
                    }
                }
                rightView()
            }
        }
        .transition(.move(edge: .bottom))
        .id(msg.id)
    }
}
