//
//  ChatView.swift
//  Conversation
//
//  Created by Aung Ko Min on 30/1/22.
//

import SwiftUI
import Introspect

struct ChatView: View {
    
    @StateObject internal var inputManager = ChatInputViewManager()
    @StateObject internal var coordinator: Coordinator
    
    init(_ conversation: Conversation) {
        _coordinator = .init(wrappedValue: .init(conversation))
    }
    
    init(_ contact: PhoneContact) {
        self.init(contact.conversation())
    }
    
    var body: some View {
        ZStack {
            ChatScrollView {
                LazyVStack(spacing: coordinator.conversation.cellSpacing) {
                    HStack {
                        if coordinator.datasource.hasMorePrevious {
                            ProgressView()
                        }
                    }
                    .frame(height: coordinator.viewComponents.topBarRect.height)
                    
                    ForEach(Array(coordinator.datasource.msgs.enumerated()), id: \.offset) { index, msg in
                        ChatCell(style: coordinator.msgStyle(for: msg, at: index))
                            .environmentObject(msg)
                    }
                    
                    HStack {
                        if coordinator.datasource.hasMoreNext {
                            ProgressView()
                        }
                    }
                    .frame(height: coordinator.viewComponents.bottomBarRect.height)
                    .id(0)
                }
                .padding(.horizontal, ChatKit.cellHorizontalPadding)
            }
            .introspectScrollView {
                coordinator.layout.connect(scrollView: $0)
            }
            .coordinateSpace(name: "ChatView")
            VStack(spacing: 0) {
                ChatTopBar()
                Spacer()
                ChatBottomBar()
                    .environmentObject(inputManager)
            }
        }
        .background(coordinator.conversation.bgImage.image)
        .accentColor(coordinator.conversation.themeColor.color)
        .retrieveBounds(viewId: ChatBottomBar.id, $coordinator.viewComponents.bottomBarRect)
        .retrieveBounds(viewId: ChatTopBar.id, $coordinator.viewComponents.topBarRect)
        .environmentObject(coordinator)
        .onReceive(NotificationCenter.default.publisher(for: .MsgNoti)) { didReceiveNoti($0) }
        .task {
            coordinator.task()
        }
        .onAppear {
            connectSocket()
        }
        .onDisappear{
            disconnectSocket()
        }
        
        
    }
}

extension ChatView {
    
    private func connectSocket() {
        IncomingSocket.shard.connect(with:  coordinator.conversation)
    }
    
    private func disconnectSocket() {
        IncomingSocket.shard.disconnect()
    }
    
    private func didReceiveNoti(_ outputt: NotificationCenter.Publisher.Output) {
        guard let noti = outputt.msgNoti else { return }
        switch noti.type {
        case .New(let msg):
            coordinator.addNewMsg(msg: msg)
            Audio.playMessageIncoming()
        case .Typing(let isTypeing):
            inputManager.isTyping = isTypeing
        case .Update(let id):
            if coordinator.conversation.refresh() {
                coordinator.objectWillChange.send()
            }
            coordinator.datasource.update(id: id)
        }
    }
}
