//
//  ChatScrollView.swift
//  Conversation
//
//  Created by Aung Ko Min on 31/1/22.
//

import SwiftUI

struct ScrollItem: Equatable {
    let id: AnyHashable
    let anchor: UnitPoint
    var animate: Bool = false
}

struct ChatScrollView<Content: View>: View {
    
    @EnvironmentObject internal var viewComponents: ViewComponents

    let content: () -> Content

    var body: some View {
        ScrollViewReader { scroller in
            ScrollView {
                content()
            }
            .onChange(of: viewComponents.scrollItem) {
                if let newValue = $0 {
                    viewComponents.scrollItem = nil
                    scroller.scroll(to: newValue)
                }
            }
        }
    }
    
}

extension ScrollViewProxy {
    
    func scroll(to item: ScrollItem) {
        if item.animate {
            withAnimation(.keyboard) {
                scrollTo(item.id, anchor: item.anchor)
            }
        } else {
            scrollTo(item.id, anchor: item.anchor)
        }
    }
}
extension Animation {
    static var keyboard: Animation {
        .interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 0.0)
    }
}
