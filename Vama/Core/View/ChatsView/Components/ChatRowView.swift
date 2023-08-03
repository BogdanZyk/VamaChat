//
//  ChatRowView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI

struct ChatRowView: View {
    let chat: Chat
    let isSelected: Bool
    let onTap: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            AvatarView(image: chat.photo, size: .init(width: 45, height: 45))
            VStack(alignment: .leading, spacing: 3){
                HStack {
                    Text(chat.title)
                        .font(.body.bold())
                    Spacer()
                    Text("\(chat.lastMessage?.createdAt ?? .now, formatter: Date.hoursAndMinuteFormatter)")
                        .font(.system(size: 10, weight: .light))
                }
                HStack(alignment: .bottom) {
                    Text(chat.lastMessage?.message ?? "")
                        .font(.caption.weight(.light))
                    Spacer()
                    if chat.unreadCount > 0{
                        Text("\(chat.unreadCount)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(width: 15, height: 15)
                            .background(Color.blue, in: Circle())
                    }
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
        ChatRowView(chat: .mocks.first!, isSelected: false, onTap: {})
    }
}
