//
//  Coordinator.swift
//  Conversation
//
//  Created by Aung Ko Min on 28/2/22.
//

import SwiftUI

class Coordinator: NSObject, ObservableObject {
    
    weak var accessoryBarManagerDelegate: AccessoryBarManagerDelegate?
    weak var datasourceDelegate: ChatDatasourceDelegagte?
    weak var viewComponentsDelegagte: ViewComponentsDelegate?
    
    private let queue = DispatchQueue(label: "com.jonahaung.conversation.coordinator")

}

// Layout
extension Coordinator {
    var canShowScrollBottom: Bool { datasourceDelegate?.hasMoreNext == true || accessoryBarManagerDelegate?.currentScrollPosition != .ClosedToBottom && accessoryBarManagerDelegate?.currentScrollPosition != .AtBottom }
}


extension Coordinator {
    
    func addNewMsg(msg: Msg) {
        queue.sync { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.datasourceDelegate?.add(msg: msg)
                if !self.canShowScrollBottom {
                    self.viewComponentsDelegagte?.scrollView?.scrollToBottom(animated: true)
                }
            }
        }
    }
    @MainActor
    func resetToBottom() {
        guard let datasourceDeelegate = datasourceDelegate else { return }
        if datasourceDeelegate.hasMoreNext {
            while datasourceDeelegate.hasMoreNext {
                datasourceDeelegate.loadNext()
            }
        }
        scrollTo(item: .init(id: 0, anchor: .bottom, animate: true))
    }
    @MainActor
    func scrollTo(item: ScrollItem?) {
        viewComponentsDelegagte?.scrollItem = item
        
    }
    
    @MainActor
    func task() {
        scrollTo(item: .init(id: 0, anchor: .bottom))
    }
}

extension Coordinator: UIScrollViewDelegate {
    
    func start(scrollView: UIScrollView) -> Bool {
        if scrollView.delegate is Self == false {
            
            scrollView.delegate = self
            return true
        }
        return false
    }
    
    private func loadPreviousIfNeeded() {
        DispatchQueue.main.async {
            guard let datasourceDeelegate = self.datasourceDelegate else { return }
            if datasourceDeelegate.hasMorePrevious, let scrollId = datasourceDeelegate.msgs.first?.id {
                datasourceDeelegate.loadPrevious()
                
                self.scrollTo(item: .init(id: scrollId, anchor: .top))
            }
        }
    }
    
    private func loadNextIfNeeded() {
        DispatchQueue.main.async {
            guard let datasourceDeelegate = self.datasourceDelegate else { return }
            if datasourceDeelegate.hasMoreNext, let scrollId = datasourceDeelegate.msgs.last?.id {
                datasourceDeelegate.loadNext()
                self.scrollTo(item: .init(id: scrollId, anchor: .bottom))
            }
        }
    }
    
    private func autoLoadMoreIfNeeded(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            loadPreviousIfNeeded()
        } else if scrollView.contentSize.height <= scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom {
            loadNextIfNeeded()
        } else if viewComponentsDelegagte?.isFirstResponder == true {
            UIApplication.shared.endEditing()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoLoadMoreIfNeeded(scrollView: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentScrollPosition(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentScrollPosition(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        guard let viewComponents = viewComponentsDelegagte else { return }
        let difference = (scrollView.adjustedContentInset.bottom - viewComponents.contentInsets.bottom)
        if difference > 0 {
            var offset = scrollView.contentOffset
            offset.y += difference
            scrollView.setContentOffset(offset, animated: true)
        }
        viewComponents.contentInsets = scrollView.adjustedContentInset
    }
    
    private func updateCurrentScrollPosition(_ scrollView: UIScrollView) {
        guard let accessoryBar = accessoryBarManagerDelegate else { return }
        accessoryBar.currentScrollPosition = scrollPosition(for: scrollView)
    }
    
    private func scrollPosition(for scrollView: UIScrollView) -> CurrentScrollPosition {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        let inset = scrollView.contentInset
        
        let closedToBottom = contentHeight - (offsetY + height - inset.bottom) < height
        let closedToTop = offsetY < height
        
        if closedToTop {
            let atTop = offsetY == -inset.top
            if atTop {
                return .AtTop
            }
            return .ClosedToTop
        } else if closedToBottom {
            let atBottom = contentHeight - offsetY == height - inset.bottom
            if atBottom {
                return .AtBottom
            }
            return .ClosedToBottom
        }
        return .Center
    }
    
}

extension Coordinator {
    
    func inputTextView(willUpdateFirstResponder isFirstResponder: Bool) -> Bool {
        guard let viewComponentsDelegagte = viewComponentsDelegagte else { return false }
        let result = viewComponentsDelegagte.isFirstResponder != isFirstResponder
        viewComponentsDelegagte.isFirstResponder = isFirstResponder
        return result
    }
    
    func inputTextView(textView: InputTextView, didChangeTextViewHeight differenc: CGFloat) {
        viewComponentsDelegagte?.scrollView?.contentOffset.y += differenc
    }
}
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
