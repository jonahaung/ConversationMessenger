//
//  TimeSeparaterCell.swift
//  Conversation
//
//  Created by Aung Ko Min on 13/2/22.
//

import SwiftUI

struct TimeSeparaterCell: View {
    
    let date: Date
    
    var body: some View {
        VStack {
            Text(MsgDateView.dateFormatter.string(for: date) ?? "No Date")
                .font(.system(size: UIFont.systemFontSize, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(height: 50)
    }
}
