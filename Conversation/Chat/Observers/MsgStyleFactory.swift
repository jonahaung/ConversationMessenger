//
//  MsgStyleFactory.swift
//  Conversation
//
//  Created by Aung Ko Min on 5/3/22.
//

import SwiftUI

protocol MsgStyleFactory: AnyObject {
    var coordinator: Coordinator { get }
    func msgStyle(for this: Msg, at index: Int) -> MsgStyle
}

extension MsgStyleFactory {
    
    func prevMsg(for msg: Msg, at i: Int) -> Msg? {
        guard i > 0 else { return nil }
        return coordinator.datasource.msgs[i - 1]
    }
    
    func nextMsg(for msg: Msg, at i: Int) -> Msg? {
        guard i < coordinator.datasource.msgs.count-1 else { return nil }
        return coordinator.datasource.msgs[i + 1]
    }
    
    func canShowTimeSeparater(_ date: Date, _ previousDate: Date) -> Bool {
        date.getDifference(from: previousDate, unit: .second) > 30
    }
    
    func msgStyle(for this: Msg, at index: Int) -> MsgStyle {
        let selectedId = coordinator.viewComponents.selectedId
//        let msgs = coordinator.datasource.msgs
        
//        let isTopItem = index == 0
//        let isBottomItem = index == msgs.count - 1
//
        let thisIsSelectedId = this.id == selectedId
        
//        let canSearchInCache = !isTopItem && !isBottomItem && !thisIsSelectedId
        
        
//        if canSearchInCache, let oldValue = cachedMsgStyles[this.id] {
//            return oldValue
//        }
        
        let isSender = this.rType == .Send
        
        var rectCornors: UIRectCorner = []
        var showAvatar = false
        var showTimeSeparater = false
        var showTopPadding = false
        
        if isSender {
            rectCornors.formUnion(.topLeft)
            rectCornors.formUnion(.bottomLeft)
            
            if let lhs = prevMsg(for: this, at: index) {
                
                showTimeSeparater = self.canShowTimeSeparater(lhs.date, this.date)
                
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
            showAvatar = this.id == coordinator.conversation.lastReadMsgId
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
                    showAvatar = coordinator.conversation.showAvatar
                }
            }else {
                rectCornors.formUnion(.bottomLeft)
            }
        }
        
        let bubbleShape = this.msgType == .Text ? BubbleShape(corners: rectCornors, cornorRadius: coordinator.conversation.bubbleCornorRadius) : nil
        
        let style = MsgStyle(bubbleShape: bubbleShape, showAvatar: showAvatar, showTimeSeparater: showTimeSeparater, showTopPadding: showTopPadding, isSelected: thisIsSelectedId)
        
//        if canSearchInCache {
//            cachedMsgStyles[this.id] = style
//        }
        return style
    }
}
