//
//  ChatLayoutManager.swift
//  Conversation
//
//  Created by Aung Ko Min on 31/1/22.
//

import SwiftUI
import UIKit

enum AutoLoadingType {
    case Previous, Next
}
enum CurrentScrollPosition {
    case AtTop, ClosedToTop, ClosedToBottom, AtBottom, Center
}


protocol ChatLayoutDelegate: AnyObject {
    @MainActor func chatLayout(layout: ChatLayout, autoLoad type: AutoLoadingType)
    @MainActor func chatLayout(layout: ChatLayout, didUpdateCurrentScrollPosition position: CurrentScrollPosition)
}

class ChatLayout: NSObject {
    
    weak var delegate: ChatLayoutDelegate?
    private weak var scrollView: UIScrollView?
    private var isFirstResponder = false

    private var contentInsets = UIEdgeInsets.zero
    
    @discardableResult
    func connect(scrollView: UIScrollView) -> Bool {
        if self.scrollView == nil {
            scrollView.keyboardDismissMode = .none
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.delegate = self
            contentInsets = scrollView.contentInset
            self.scrollView = scrollView
            
            return true
        }
        return false
    }
    
    deinit{
        Log("")
    }
}

// UIScrollView Delegate

extension ChatLayout: UIScrollViewDelegate {
    
    var shouldScrollToBottom: Bool {
        guard let scrollView = scrollView else { return false }
        return scrollView.isCloseToBottom()
    }

    func scrollToBottom() {
        guard let scrollView = scrollView else {
            return
        }
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height
        UIView.animate(withDuration: 0.2) {
            scrollView.contentOffset = offset
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isFirstResponder {
            UIApplication.shared.endEditing()
        } else {
            autoLoadMoreIfNeeded(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentScrollPosition()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentScrollPosition()
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        guard scrollView.contentInset.top == contentInsets.top else {
            self.contentInsets = scrollView.contentInset
            return
        }
        let difference = scrollView.adjustedContentInset.bottom - contentInsets.bottom
        if isFirstResponder && difference > 0 {
            var offset = scrollView.contentOffset
            offset.y += difference
            scrollView.setContentOffset(offset, animated: isFirstResponder)
        }
        self.contentInsets = scrollView.adjustedContentInset
    }
    
    @MainActor private func updateCurrentScrollPosition() {
        guard let scrollView = scrollView else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        let inset = scrollView.contentInset
        
        let closedToBottom = contentHeight - height < offsetY
        let closedToTop = offsetY < height
        if closedToTop {
            let atTop = offsetY == -inset.top
            if atTop {
                delegate?.chatLayout(layout: self, didUpdateCurrentScrollPosition: .AtTop)
            } else {
                delegate?.chatLayout(layout: self, didUpdateCurrentScrollPosition: .ClosedToTop)
            }
        } else if closedToBottom {
            let atBottom = contentHeight - offsetY == height - inset.bottom
            if atBottom {
                delegate?.chatLayout(layout: self, didUpdateCurrentScrollPosition: .AtBottom)
            } else {
                delegate?.chatLayout(layout: self, didUpdateCurrentScrollPosition: .ClosedToBottom)
            }
        } else {
            delegate?.chatLayout(layout: self, didUpdateCurrentScrollPosition: .Center)
        }
    }
}


// Auto Loading

extension ChatLayout {
    
    @MainActor private func autoLoadMoreIfNeeded(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            delegate?.chatLayout(layout: self, autoLoad: .Previous)
        } else if scrollView.isDragging, scrollView.contentSize.height <= scrollView.contentOffset.y + scrollView.frame.size.height {
            delegate?.chatLayout(layout: self, autoLoad: .Next)
        }
    }
}
extension ChatLayout {
    
    func inputTextView(willUpdateFirstResponder isFirstResponder: Bool) -> Bool {
        let result = self.isFirstResponder != isFirstResponder
        self.isFirstResponder = isFirstResponder
        return result
    }
    
    func inputTextView(textView: InputTextView, didChangeTextViewHeight differenc: CGFloat) {
        guard let scrollView = scrollView else { return }
        var offset = scrollView.contentOffset
        offset.y += differenc
        scrollView.setContentOffset(offset, animated: true)
    }
}
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
