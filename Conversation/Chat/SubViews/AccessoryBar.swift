//
//  AccessoryBar.swift
//  Conversation
//
//  Created by Aung Ko Min on 14/3/22.
//

import SwiftUI

struct AccessoryBar: View {
    
    @EnvironmentObject internal var viewComponents: ViewComponents
    @EnvironmentObject internal var coordinator: Coordinator
    @EnvironmentObject internal var manager: Manager
    
    var body: some View {
        HStack(alignment: .bottom) {
            if manager.isTyping {
                TypingView()
            }
            
            Spacer()
            if coordinator.canShowScrollBottom {
                Button {
                    coordinator.resetToBottom()
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding()
                }
                .transition(.scale)
            }
        }
    }
}

protocol AccessoryBarManagerDelegate: AnyObject {
    var isTyping: Bool { get set }
    var currentScrollPosition: CurrentScrollPosition { get set }
}
extension AccessoryBar {
    
    class Manager: ObservableObject, AccessoryBarManagerDelegate {
        @Published var isTyping = false
        @Published var currentScrollPosition = CurrentScrollPosition.AtBottom
    }
}
