//
//  ChatInputView.swift
//  Conversation
//
//  Created by Aung Ko Min on 30/1/22.
//

import SwiftUI

struct ChatBottomBar: View, LocationMsgSendable, PhotoMsgSendable {
    
    static let id = 1

    @StateObject internal var inputManager = ChatInputViewManager()
    @EnvironmentObject internal var coordinator: Coordinator
    @EnvironmentObject internal var conversation: Conversation
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            Group {
                switch inputManager.currentInputItem {
                case .ToolBar:
                    InputMenuBar {
                        inputManager.currentInputItem = $0 == .ToolBar ? .Text : $0
                    }
                case .Camera:
                    CameraPicker(onSendPhoto: sendPhoto(image:))
                case .Location:
                    LocationPicker(onSend: sendLocation(coordinate:))
                case .PhotoLibrary:
                    PhotoPicker{ image in
                        sendPhoto(image: image)
                    }
                case .Text:
                    TextBar()
                default:
                    InputPicker {
                        Text(String(describing: inputManager.currentInputItem))
                    } onSend: {
                        
                    }
                }
            }
        }
        .background(.regularMaterial)
        .saveBounds(viewId: ChatBottomBar.id, coordinateSpace: .named("ChatView"))
        .environmentObject(inputManager)
    }
}
