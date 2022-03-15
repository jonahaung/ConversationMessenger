//
//  ChatKit.swift
//  Conversation
//
//  Created by Aung Ko Min on 13/2/22.
//


import SwiftUI

enum ChatKit {

    enum ChatCell {
        static let flexiableSpacing = CGFloat(30)
        static let statusViewSize = CGFloat(15)
        enum TextBubble {
            static let insets = CGSize(width: 12, height: 6)
            static let bgColorIncoming = Color(uiColor: .secondarySystemGroupedBackground)
            static let bgColorIncomingDefault = Color(uiColor: .systemGray6)
            static let textColorOutgoing = Color(uiColor: UIColor.systemBackground)
            static let textColorIncoming: Color? = nil
        }
        enum LocationBubble {
            static let size = CGSize(width: 280, height: 200)
        }
    }

    
    static let mediaMaxWidth = CGFloat(250)
    
}
