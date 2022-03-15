//
//  ChatView.swift
//  Conversation
//
//  Created by Aung Ko Min on 30/1/22.
//

import SwiftUI
import Introspect

struct ChatView: View {
    
    @StateObject var conversation: Conversation
    @StateObject internal var coordinator: Coordinator = Coordinator()
    @StateObject private var viewComponents: ViewComponents
    @StateObject private var datasource: ChatDatasource
    @StateObject private var accessoryBarManager = AccessoryBar.Manager()
    
    init(_ conversation: Conversation) {
        let vComponents = ViewComponents()
        let dSource = ChatDatasource(conId: conversation.id)
        _conversation = .init(wrappedValue: conversation)
        _viewComponents = .init(wrappedValue: vComponents)
        _datasource = .init(wrappedValue: dSource)
        
    }
    
    init(_ contact: PhoneContact) {
        self.init(contact.conversation())
    }
    
    var body: some View {
        ZStack {
            ChatScrollView {
                LazyVStack(spacing: conversation.cellSpacing) {
                    VStack {
                        if datasource.hasMorePrevious {
                            ProgressView()
                        }
                    }
                    .frame(height: viewComponents.topBarRect.height)
                    
                    ForEach(Array(datasource.msgs.enumerated()), id: \.offset) { index, msg in
                        ChatCell(style: msgStyle(for: msg, at: index))
                            .environmentObject(msg)
                    }
                    
                    VStack {
                        if datasource.hasMoreNext {
                            ProgressView()
                        }
                    }
                    .frame(height: viewComponents.bottomBarRect.height)
                    .id(0)
                }
                .padding(.horizontal, 8)
            }
            .introspectScrollView { scrollView in
                if coordinator.start(scrollView: scrollView) {
                    scrollView.keyboardDismissMode = .none
                    scrollView.contentInsetAdjustmentBehavior = .never
                    viewComponents.scrollView = scrollView
                    viewComponents.contentInsets = scrollView.contentInset
                }
            }
            VStack(spacing: 0) {
                ChatTopBar()
                Spacer()
                AccessoryBar()
                    .environmentObject(accessoryBarManager)
                ChatBottomBar()
            }
        }
        .coordinateSpace(name: "ChatView")
        .background(conversation.bgImage.image)
        .accentColor(conversation.themeColor.color)
        .retrieveBounds(viewId: ChatBottomBar.id, $viewComponents.bottomBarRect)
        .retrieveBounds(viewId: ChatTopBar.id, $viewComponents.topBarRect)
        
        .onReceive(NotificationCenter.default.publisher(for: .MsgNoti)) { didReceiveNoti($0) }
        .task {
            coordinator.viewComponentsDelegagte = viewComponents
            coordinator.accessoryBarManagerDelegate = accessoryBarManager
            coordinator.datasourceDelegate = datasource
            coordinator.task()
        }
        .onAppear {
            connectSocket()
        }
        .onDisappear{
            disconnectSocket()
        }
        .environmentObject(coordinator)
        .environmentObject(viewComponents)
        .environmentObject(datasource)
        .environmentObject(conversation)
    }
}

extension ChatView {
    
    private func connectSocket() {
        IncomingSocket.shard.connect(with:  conversation)
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
            accessoryBarManager.isTyping = isTypeing
        case .Update(let id):
            datasource.update(id: id)
        }
    }
}

extension ChatView {
    func prevMsg(for msg: Msg, at i: Int) -> Msg? {
        guard i > 0 else { return nil }
        return datasource.msgs[i - 1]
    }
    
    func nextMsg(for msg: Msg, at i: Int) -> Msg? {
        guard i < datasource.msgs.count-1 else { return nil }
        return datasource.msgs[i + 1]
    }
    
    func canShowTimeSeparater(_ date: Date, _ previousDate: Date) -> Bool {
        date.getDifference(from: previousDate, unit: .second) > 30
    }
    
    func msgStyle(for this: Msg, at index: Int) -> MsgStyle {
        let selectedId = viewComponents.selectedId
        let thisIsSelectedId = this.id == selectedId
        let isSender = this.rType == .Send
        
        var rectCornors: UIRectCorner = []
        var showAvatar = false
        var showTimeSeparater = false
        var showTopPadding = false
        
        if isSender {
            rectCornors.formUnion(.topLeft)
            rectCornors.formUnion(.bottomLeft)
            
            if let lhs = prevMsg(for: this, at: index) {
                
                showTimeSeparater = self.canShowTimeSeparater(this.date, lhs.date)
                
                if
                    (this.rType != lhs.rType ||
                     this.msgType != lhs.msgType ||
                     thisIsSelectedId ||
                     lhs.id == selectedId ||
                     showTimeSeparater) {
                    
                    rectCornors.formUnion(.topRight)
                    
                    showTopPadding = !showTimeSeparater && this.rType != lhs.rType
                }
            } else {
                rectCornors.formUnion(.topRight)
            }
            
            if let rhs = nextMsg(for: this, at: index) {
                
                if
                    (this.rType != rhs.rType ||
                     this.msgType != rhs.msgType ||
                     thisIsSelectedId ||
                     rhs.id == selectedId ||
                     self.canShowTimeSeparater(this.date, rhs.date)) {
                    rectCornors.formUnion(.bottomRight)
                }
            }else {
                rectCornors.formUnion(.bottomRight)
            }
            showAvatar = this.id == conversation.lastReadMsgId
        } else {
            
            rectCornors.formUnion(.topRight)
            rectCornors.formUnion(.bottomRight)
            
            if let lhs = prevMsg(for: this, at: index) {
                
                showTimeSeparater = self.canShowTimeSeparater(this.date, lhs.date)
                
                if
                    (this.rType != lhs.rType ||
                     this.msgType != lhs.msgType ||
                     thisIsSelectedId ||
                     lhs.id == selectedId ||
                     showTimeSeparater) {
                    
                    rectCornors.formUnion(.topLeft)
                    
                    showTopPadding = !showTimeSeparater && this.rType != lhs.rType
                }
            } else {
                rectCornors.formUnion(.topLeft)
            }
            
            if let rhs = nextMsg(for: this, at: index) {
                if
                    (this.rType != rhs.rType ||
                     this.msgType != rhs.msgType ||
                     thisIsSelectedId ||
                     rhs.id == selectedId ||
                     self.canShowTimeSeparater(rhs.date, this.date)) {
                    rectCornors.formUnion(.bottomLeft)
                    showAvatar = conversation.showAvatar
                }
            }else {
                rectCornors.formUnion(.bottomLeft)
            }
        }
        
        let bubbleShape = this.msgType == .Text ? BubbleShape(corners: rectCornors, cornorRadius: conversation.bubbleCornorRadius) : nil
        
        let style = MsgStyle(bubbleShape: bubbleShape, showAvatar: showAvatar, showTimeSeparater: showTimeSeparater, showTopPadding: showTopPadding, isSelected: thisIsSelectedId)
        return style
    }
    
}
