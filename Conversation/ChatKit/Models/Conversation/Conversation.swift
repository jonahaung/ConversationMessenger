//
//  Con.swift
//  Conversation
//
//  Created by Aung Ko Min on 27/2/22.
//

import SwiftUI

class Conversation: ObservableObject, Identifiable {
    
    let id: String
    let date: Date
    
    var name: String {
        willSet {
            self.cCon()?.name = newValue
        }
    }
    
    var bgImage: BgImage {
        willSet {
            self.cCon()?.bgImage = newValue.rawValue
            objectWillChange.send()
        }
    }
    var bubbleCornorRadius: CGFloat {
        willSet {
            self.cCon()?.bubbleCornorRadius = Int16(newValue)
            objectWillChange.send()
        }
    }
    var themeColor: ThemeColor{
        willSet {
            self.cCon()?.themeColor = newValue.rawValue
            objectWillChange.send()
        }
    }
    
    var cellSpacing: CGFloat {
        willSet {
            self.cCon()?.cellSpacing = Int16(newValue)
            objectWillChange.send()
        }
    }
    
    var showAvatar: Bool {
        willSet {
            self.cCon()?.showAvatar = newValue
            objectWillChange.send()
        }
    }
    
    var isPagingEnabled: Bool {
        willSet {
            self.cCon()?.isPagingEnabled = newValue
            objectWillChange.send()
        }
    }
    
    var lastReadMsgId: String?
    
    init(cCon: CCon) {
        self.id = cCon.id!
        self.name = cCon.name!
        self.date = cCon.date!
        self.bgImage = BgImage(rawValue: cCon.bgImage) ?? .None
        self.themeColor = ThemeColor(rawValue: cCon.themeColor) ?? .Blue
        self.cellSpacing = CGFloat(cCon.cellSpacing)
        
        self.showAvatar = cCon.showAvatar
        self.isPagingEnabled = cCon.isPagingEnabled
        self.lastReadMsgId = cCon.lastReadMsgId
        self.bubbleCornorRadius = CGFloat(cCon.bubbleCornorRadius)
    }
    
    func msgsCount() -> Int {
        CMsg.count(for: id)
    }
    
    func lastMsg() -> Msg? {
        if let cMsg = CMsg.lastMsg(for: id) {
            return Msg(cMsg: cMsg)
        }
        return nil
    }
    
    func cCon() -> CCon? {
        CCon.cCon(for: id)
    }
    
    @discardableResult
    func refresh() -> Bool {
        guard let cCon = self.cCon() else { return false }
        var returnValue = false
        if self.name != cCon.name {
            self.name = cCon.name!
            returnValue = true
        }
        let bgImage = BgImage(rawValue: cCon.bgImage) ?? .None
        if self.bgImage != bgImage {
            self.bgImage = bgImage
            returnValue = true
        }
        
        let themeColor = ThemeColor(rawValue: cCon.themeColor) ?? .Blue
        if self.themeColor != themeColor {
            self.themeColor = themeColor
            returnValue = true
        }
        
        let cellSpacing = CGFloat(cCon.cellSpacing)
        if self.cellSpacing != cellSpacing {
            self.cellSpacing = cellSpacing
            returnValue = true
        }
    
        if self.showAvatar != cCon.showAvatar {
            self.showAvatar = cCon.showAvatar
            returnValue = true
        }
        if self.isPagingEnabled != cCon.isPagingEnabled {
            self.isPagingEnabled = cCon.isPagingEnabled
            returnValue = true
        }
        if self.lastReadMsgId != cCon.lastReadMsgId {
            self.lastReadMsgId = cCon.lastReadMsgId
            returnValue = true
        }
        if !cCon.hasMsgs && self.msgsCount() > 0 {
            cCon.hasMsgs = true
        }
        return returnValue
    }
}

extension Conversation {
    func bubbleColor(for msg: Msg) -> Color {
        return msg.rType == .Send ? themeColor.color : bgImage == .None ? ChatKit.ChatCell.TextBubble.bgColorIncomingDefault : ChatKit.ChatCell.TextBubble.bgColorIncoming
    }
}
