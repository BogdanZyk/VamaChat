//
//  ChatRowView+LastMessagePreview.swift
//  Vama
//
//  Created by Bogdan Zykov on 15.08.2023.
//

import SwiftUI

extension ChatRowView {
    
    var chatLastMessagePreview: some View {
        HStack(alignment: .bottom) {
            Group{
                if let draft = chatData.draftMessage {
                    HStack(alignment: .top, spacing: 2) {
                        Text("Draft:")
                            .foregroundColor(.red)
                        Text(draft)
                    }
                } else {
                    lastMessageContent
                }
            }
            .font(.caption.weight(.light))
            Spacer()
            messageViewedIcon
        }
    }
    
    @ViewBuilder
    private var lastMessageContent: some View {
        if let message = chatData.chat.lastMessage?.message {
            HStack {
                imagePreview
                Text(message)
            }
        } else if let medias = chatData.chat.lastMessage?.media {
            HStack{
                imagePreview
                Text("\(medias.count) photo")
            }
        }
    }
    
    @ViewBuilder
    private var imagePreview: some View {
        if let path = chatData.chat.lastMessage?.media?.first?.item?.fullPath {
            LazyNukeImage(strUrl: path)
                .cornerRadius(5)
                .frame(width: 16, height: 16)
        }
    }
    
    @ViewBuilder
    private var messageViewedIcon: some View {
        if let currentUID, !(chatData.chat.lastMessage?.viewMessage(for: currentUID) ?? true) {
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
        }
    }
}
