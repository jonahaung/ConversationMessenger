//
//  +UIScrollView.swift
//  Conversation
//
//  Created by Aung Ko Min on 28/2/22.
//

import UIKit

extension UIScrollView {
    
    func isCloseToBottom() -> Bool {
        guard self.contentSize.height > 0 else { return false }
        return contentSize.height - contentOffset.y < bounds.height + contentInset.top + contentInset.bottom
//        return (self.visibleRect().maxY / self.contentSize.height) > (1 - 0.01)
    }
    
    func isCloseToTop() -> Bool {
        guard self.contentSize.height > 0 else { return true }
        return (self.visibleRect().minY / self.contentSize.height) < 0.01
    }
    
    func visibleRect() -> CGRect {
        return CGRect(x: CGFloat(0), y: self.contentOffset.y + contentInset.top, width: self.bounds.width, height: min(contentSize.height, self.bounds.height - contentInset.top - contentInset.bottom))
    }
    
    func scrollToBottom(animated: Bool) {
        
        var offset = contentOffset
        offset.y = self.contentSize.height
        if animated {
            UIView.animateKeyframes(withDuration: 0.18, delay: 0.1, options: [.beginFromCurrentState, .overrideInheritedOptions]) {
                self.contentOffset = offset
            }

        } else {
            self.contentOffset = offset
        }
    }
    
    func scrollToPreservePosition(oldRefRect: CGRect?, newRefRect: CGRect?) {
        guard let oldRefRect = oldRefRect, let newRefRect = newRefRect else {
            return
        }
        let diffY = newRefRect.minY - oldRefRect.minY
        self.contentOffset = CGPoint(x: 0, y: self.contentOffset.y + diffY)
    }
    
    func stop() {
        setContentOffset(contentOffset, animated: false)
    }
}
