//
//  +CContact.swift
//  Conversation
//
//  Created by Aung Ko Min on 7/3/22.
//

import CoreData

extension PhoneContact {
    
    var conId: String {
        return id > CurrentUser.shared.user.id ? CurrentUser.shared.user.id + id : id + CurrentUser.shared.user.id
    }
    
    func conversation() -> Conversation {
        let conId = self.conId
        if let cCon = CCon.cCon(for: conId), Conversation(cCon: cCon).lastMsg() != nil  {
            return Conversation(cCon: cCon)
        } else {
            let cCon = CCon.fetchOrCreate(contact: self)
            return Conversation(cCon: cCon)
        }
    }
    
}
