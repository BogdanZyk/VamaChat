//
//  ChatViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation


final class ChatViewModel: ObservableObject{
    
    @Published var chats: [ChatConversation] = []
    @Published var selectedChat: ChatConversation?
   
    
    init(){
        fetchChats()
    }
    
    func fetchChats(){
        createConversations(for: "1", chats: Chat.mocks)
    }
    
    
    func createConversations(for userId: String, chats: [Chat]){

        let usersIds = chats.compactMap({$0.participantsIds.first(where: {$0 != userId})})
        let users = [ShortUser.mock]
        
        chats.forEach { chat in
            let target = users.first(where: {chat.participantsIds.contains($0.id) && chat.chatType == .chatPrivate})
            self.chats.append(.init(chat: chat, target: target))
        }
    }
}


