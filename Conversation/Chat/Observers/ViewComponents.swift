//
//  ViewComponents.swift
//  Conversation
//
//  Created by Aung Ko Min on 14/3/22.
//

import SwiftUI

enum AutoLoadingType {
    case Previous, Next
}
enum CurrentScrollPosition {
    case AtTop, ClosedToTop, ClosedToBottom, AtBottom, Center
}

protocol ViewComponentsDelegate: AnyObject {
    var scrollItem: ScrollItem? { get set }
    var scrollView: UIScrollView? { get }
    var selectedId: String? { get set }
    var isFirstResponder: Bool { get set }
    var contentInsets: UIEdgeInsets { get set }
    var  bottomBarRect: CGRect { get set }
    var  topBarRect: CGRect  { get set }
}

class ViewComponents: ObservableObject, ViewComponentsDelegate {
    
    @Published var selectedId: String?
    @Published var scrollItem: ScrollItem?
    @Published var  topBarRect: CGRect = .zero
    @Published var  bottomBarRect: CGRect = .zero
    var isFirstResponder = false
    var contentInsets = UIEdgeInsets.zero
    weak var scrollView: UIScrollView?

    deinit {
        Log("")
    }
}
