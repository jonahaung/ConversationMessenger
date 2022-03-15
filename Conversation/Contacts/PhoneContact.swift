//
//  Contact.swift
//  Conversation
//
//  Created by Aung Ko Min on 7/3/22.
//

import Contacts

class PhoneContact: ObservableObject, Identifiable {
   
    var id: String { phoneNumber }
    var name: String?
    var avatarData: Data?
    var phoneNumber: String
    
    init(contact: CNContact) {
        name = contact.givenName + " " + contact.familyName
        avatarData = contact.thumbnailImageData
        phoneNumber = contact.phoneNumbers.filter{ $0.label == CNLabelPhoneNumberMobile }.first?.value.stringValue ?? ""
        avatarData = contact.thumbnailImageData
    }
}

extension PhoneContact: Hashable {
    static func == (lhs: PhoneContact, rhs: PhoneContact) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
