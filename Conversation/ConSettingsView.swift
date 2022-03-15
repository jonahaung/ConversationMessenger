//
//  RoomPropertiesView.swift
//  Conversation
//
//  Created by Aung Ko Min on 12/2/22.
//

import SwiftUI

struct ConSettingsView: View {
    
    @EnvironmentObject private var conversation: Conversation
    
    var body: some View {
        Form {
            Text(conversation.name)
            Toggle("Show Avatar", isOn: $conversation.showAvatar)
            Toggle("Paginition Enabled", isOn: $conversation.isPagingEnabled)
            
            Picker(selection: $conversation.themeColor) {
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
            
            Stepper("Cell Spacing  \(Int(conversation.cellSpacing))", value: $conversation.cellSpacing, in: 0...10)
            Stepper("Bubble Cornor Radius  \(Int(conversation.bubbleCornorRadius))", value: $conversation.bubbleCornorRadius, in: 0...30)
            
            Picker(selection: $conversation.bgImage) {
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
