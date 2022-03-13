//
//  Coordinator.swift
//  Conversation
//
//  Created by Aung Ko Min on 28/2/22.
//

import SwiftUI
import Combine

struct ViewComponents {
    var topBarRect: CGRect = .zero
    var bottomBarRect: CGRect = .zero
    var selectedId: String?
}

class Coordinator: ObservableObject {
    
    @Published var conversation: Conversation
    @Published var scrollItem: ScrollItem?
    var viewComponents = ViewComponents()
    
    private var currentScrollPosition = CurrentScrollPosition.AtBottom
    
    var datasource: ChatDatasource
    var layout = ChatLayout()
    
    private let queue: OperationQueue = {
        $0.name = "Coordinator"
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    init(_ conversation: Conversation) {
        self.conversation = conversation
        self.datasource = .init(conId: conversation.id)
    }
    
    deinit {
        queue.cancelAllOperations()
        Log("Deinit")
    }
}
// Layout
extension Coordinator: ChatLayoutDelegate {
    
    var canShowScrollBottom: Bool { datasource.hasMoreNext || currentScrollPosition != .ClosedToBottom && currentScrollPosition != .AtBottom }
    

    @MainActor private func loadPreviousIfNeeded() {
        if datasource.hasMorePrevious, let scrollId = datasource.msgs.first?.id {
            datasource.loadPrevious()
            updateUI()
            scrollTo(item: .init(id: scrollId, anchor: .top))
        }
    }
    
    @MainActor private func loadNextIfNeeded() {
        if datasource.hasMoreNext, let scrollId = datasource.msgs.last?.id {
            datasource.loadNext()
            updateUI()
            scrollTo(item: .init(id: scrollId, anchor: .bottom))
        }
    }
    
    func chatLayout(layout: ChatLayout, autoLoad type: AutoLoadingType) {
        switch type {
        case .Previous:
            loadPreviousIfNeeded()
        case .Next:
            loadNextIfNeeded()
        }
    }
    
    func chatLayout(layout: ChatLayout, didUpdateCurrentScrollPosition position: CurrentScrollPosition) {
        if self.currentScrollPosition != position {
            self.currentScrollPosition = position
            updateUI()
        }
    }
}


extension Coordinator {
    
    func addNewMsg(msg: Msg) {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.datasource.add(msg: msg)
                self.updateUI()
                if !self.canShowScrollBottom {
                    self.scrollTo(item: .init(id: 0, anchor: .bottom, animate: true))
//                    self.layout.scrollToBottom()
                }
            }
        }
    }
    @MainActor
    func resetToBottom() {
        if datasource.hasMoreNext {
            datasource = ChatDatasource(conId: conversation.id)
        }
        scrollTo(item: .init(id: 0, anchor: .bottom, animate: true))
    }
    @MainActor
    private func scrollTo(item: ScrollItem?) {
        scrollItem = item
        
    }
    @MainActor
    private func updateUI() {
        objectWillChange.send()
    }
    
    @MainActor func task() {
        if layout.delegate == nil {
            layout.delegate = self
            scrollTo(item: .init(id: 0, anchor: .bottom))
        }
    }
}

extension Coordinator: MsgStyleFactory {
    var coordinator: Coordinator { return self }
}
