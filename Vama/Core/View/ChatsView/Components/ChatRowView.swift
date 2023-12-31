//
//  ChatRowView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI

struct ChatRowView: View {
    let currentUID: String?
    let chatData: ChatConversation
    let isSelected: Bool
    let onTap: (ChatConversation) -> Void
    let onContextAction: (ChatContextAction, String) -> Void
    private var isPrivateChat: Bool{
        chatData.chat.chatType == .chatPrivate
    }
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            chatPhoto
            VStack(alignment: .leading, spacing: 3){
                chatInfo
                chatLastMessagePreview
            }
        }
        .hLeading()
        .padding(10)
        .background(Color.gray.opacity(isSelected ? 0.2 : 0))
        .contentShape(Rectangle())
        .overlay(alignment: .bottom){
            if !isSelected{
                Divider()
                    .padding(.trailing, -10)
                    .padding(.leading, 60)
            }
        }
        .onTapGesture {
            onTap(chatData)
        }
        .contextMenu{contextMenuContent}
    }
}

struct ChatRowView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRowView(currentUID: "123", chatData: .mocks.first!, isSelected: false, onTap: {_ in}, onContextAction: {_, _ in})
    }
}


extension ChatRowView{
    
    private var chatPhoto: some View{
        AvatarView(image: isPrivateChat ? chatData.target?.image : chatData.chat.photo, size: .init(width: 45, height: 45))
    }
    
    private var chatTitle: some View{
        Text(isPrivateChat ? (chatData.target?.fullName ?? "") : chatData.chat.title ?? "")
            .font(.body.bold())
    }
    
    private var chatInfo: some View{
        HStack {
            chatTitle
            Spacer()
            if let date = chatData.chat.lastMessage?.createdAt.date{
                Text("\(date.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 10, weight: .light))
            }
        }
    }
    
    private var contextMenuContent: some View{
        ForEach(ChatContextAction.allCases, id: \.self) { type in
            Button {
                onContextAction(type, chatData.id)
            } label: {
                HStack {
                    Image(systemName: type.image)
                    Text(type.title)
                }
                .foregroundColor(type == .remove ? .red : .primary)
                .padding()
            }
        }
    }
}
