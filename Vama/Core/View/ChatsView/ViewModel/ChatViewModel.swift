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
    private let userService = UserService.share
    
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
    
    func onSetDraft(_ draftText: String?, id: String){
        guard let index = chats.firstIndex(where: {$0.id == id}) else {return}
        chats[index].draftMessage = draftText
    }
    
    func selectChat(_ chat: ChatConversation){
        selectedChat = chat
    }
    
    func setChatAction(_ action: ChatContextAction, _ id: String){
        switch action {
        case .pin:
            print("pin chat")
        case .archive:
            print("archive chat")
        case .clear:
            print("Clear chat")
        case .remove:
            print("Remove chat")
        }
    }
}


