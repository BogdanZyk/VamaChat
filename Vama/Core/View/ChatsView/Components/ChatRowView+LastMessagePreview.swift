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
        if let forwardMessage = chatData.chat.lastMessage?.forwardMessages?.first{
            HStack(spacing: 5) {
                Image(systemName: "arrowshape.turn.up.left.fill")
                    .font(.caption)
                messageContent(forwardMessage.message)
            }
        } else if let message = chatData.chat.lastMessage {
            messageContent(message)
        }
    }
    
    @ViewBuilder
    private func messageContent(_ message: Message) -> some View {
        if let text = message.message {
            HStack {
                makeImagePreview(message)
                Text(text)
            }
        } else if let medias = message.media, !medias.isEmpty {
            HStack{
                makeImagePreview(message)
                Text("\(medias.count) photo")
            }
        }
    }
    
    
    @ViewBuilder
    private func makeImagePreview(_ message: Message) -> some View {
        if let path = message.media?.first?.item?.fullPath {
            LazyNukeImage(strUrl: path)
                .cornerRadius(2)
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
