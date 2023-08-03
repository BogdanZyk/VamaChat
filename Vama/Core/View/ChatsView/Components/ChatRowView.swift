//
//  ChatRowView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI

struct ChatRowView: View {
    let chatData: ChatConversation
    let isSelected: Bool
    let onTap: () -> Void
    private var isPrivateChat: Bool{
        chatData.chat.chatType == .chatPrivate
    }
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            chatPhoto
            VStack(alignment: .leading, spacing: 3){
                HStack {
                    chatTitle
                    Spacer()
                    Text("\(chatData.chat.lastMessage?.createdAt ?? .now, formatter: Date.hoursAndMinuteFormatter)")
                        .font(.system(size: 10, weight: .light))
                }
                HStack(alignment: .bottom) {
                    Text(chatData.chat.lastMessage?.message ?? "")
                        .font(.caption.weight(.light))
                    Spacer()
//                    if chat.unreadCount > 0{
//                        Text("\(chat.unreadCount)")
//                            .font(.caption2)
//                            .foregroundColor(.white)
//                            .frame(width: 15, height: 15)
//                            .background(Color.blue, in: Circle())
//                    }
                }
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
            onTap()
        }
    }
}

struct ChatRowView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRowView(chatData: .mocks.first!, isSelected: false, onTap: {})
    }
}


extension ChatRowView{
    
    private var chatPhoto: some View{
        AvatarView(image: isPrivateChat ? chatData.target?.image : chatData.chat.photo, size: .init(width: 45, height: 45))
    }
    
    private var chatTitle: some View{
        Text(isPrivateChat ? (chatData.target?.name ?? "") : chatData.chat.title ?? "")
            .font(.body.bold())
    }
}
