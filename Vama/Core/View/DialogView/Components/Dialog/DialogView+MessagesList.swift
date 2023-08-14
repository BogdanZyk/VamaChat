//
//  DialogView+MessagesList.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension DialogView {
    
    var messagesList: some View{
        LazyVStack(spacing: 0, pinnedViews: .sectionFooters){
            let chunkedMessages = viewModel.messages.chunked(by: {$0.message.createdAt.date.isSameDay(as: $1.message.createdAt.date)})
            ForEach(chunkedMessages.indices, id: \.self){ index in
                Section {
                    let messages = chunkedMessages[index]
                    ForEach(messages.indices, id: \.self) { index in
                        let isOneByOne = isOneByOneMessages(messages, index: index)
                        makeMessageRow(messages[index], isOneByOne: isOneByOne)
                    }
                } footer: {
                    if let date = chunkedMessages[index].first?.message.createdAt.date{
                        messagesDateLabel(date)
                    }
                }
            }
        }
    }
    
    private func messagesDateLabel(_ date: Date) -> some View{
        Text(date.toFormatDate().capitalized)
            .font(.footnote.weight(.medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Material.ultraThinMaterial, in: Capsule())
            .padding(.vertical, 5)
            .flippedUpsideDown()
    }
    
    ///One message after another from the same user
    private func isOneByOneMessages(_ messages: ArraySlice<DialogMessage>, index: Int) -> Bool {
        guard index >= 0 && index < messages.count - 1 else {
            return false
        }
        return messages[index].message.fromId == messages[index + 1].message.fromId
    }
    
}
