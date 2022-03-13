//
//  RoomPropertiesView.swift
//  Conversation
//
//  Created by Aung Ko Min on 12/2/22.
//

import SwiftUI

struct ConSettingsView: View {
    
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        Form {
            Text(coordinator.conversation.name)
            Toggle("Show Avatar", isOn: $coordinator.conversation.showAvatar)
            Toggle("Bubble Drag", isOn: $coordinator.conversation.isBubbleDraggable)
            Toggle("Paginition Enabled", isOn: $coordinator.conversation.isPagingEnabled)
            
            Picker(selection: $coordinator.conversation.themeColor) {
                ForEach(Conversation.ThemeColor.allCases, id: \.self) { themeColor in
                    Label {
                        Text(themeColor.name)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundColor(themeColor.color)
                    }
                }
            } label: {
                Text("Theme Color")
            }
            
            Stepper("Cell Spacing  \(Int(coordinator.conversation.cellSpacing))", value: $coordinator.conversation.cellSpacing, in: 0...10)
            Stepper("Bubble Cornor Radius  \(Int(coordinator.conversation.bubbleCornorRadius))", value: $coordinator.conversation.bubbleCornorRadius, in: 0...30)
            
            Picker(selection: $coordinator.conversation.bgImage) {
                ForEach(Conversation.BgImage.allCases, id: \.self) { bgImage in
                    bgImage.image
                        .padding()
                }
            } label: {
                Text("")
            }
            .labelsHidden()
        }
        .navigationTitle("Conversation Settings")
    }
}
