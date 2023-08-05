//
//  ChatViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation

@MainActor
final class ChatViewModel: ObservableObject{
    
    @Published var chats: [ChatConversation] = []
    @Published var selectedChat: ChatConversation?
    private let userService = UserService.share
    private let chatService = ChatServices.shared
    
    
    var currentUID: String?{
        userService.getFBUserId()
    }
    
    init(){
        fetchChats()
    }
    

    func fetchChats(){
        guard let currentUID else {return}
        Task{
            do{
                let chats = try await chatService.getUserChats(userId: currentUID)
                let chatConversations = try await createChatConversations(for: currentUID, chats: chats)
                
                await MainActor.run {
                    self.chats = chatConversations
                }
                
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func createChatConversations(for userId: String, chats: [Chat]) async throws -> [ChatConversation]{
        let userIds = chats.compactMap({$0.participantsIds.first(where: {$0 != userId})})
        let users = try await userService.getUsers(ids: userIds).map({ShortUser(user: $0)})
        var conversations = [ChatConversation]()
        chats.forEach { chat in
            let target = users.first(where: {chat.participantsIds.contains($0.id)})
            conversations.append(.init(chat: chat, target: target))
        }
        return conversations
    }
    
    func onSetDraft(_ draftText: String?, id: String){
        guard let index = chats.firstIndex(where: {$0.id == id}) else {return}
        chats[index].draftMessage = draftText
    }
    
    func selectChatConversation(_ chat: ChatConversation){
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


extension ChatViewModel{
    
    func createChatConversation(for target: ShortUser){
        
        guard let currentUID, currentUID != target.id else {return}
        
        if let existConversation = chats.first(where: {$0.target?.id == target.id}){
            selectChatConversation(existConversation)
        }else{
            let chat = Chat(id: UUID().uuidString, chatType: .chatPrivate, lastMessage: nil, participantsIds: [currentUID, target.id])
            let conversation = ChatConversation(chat: chat, target: target, draftMessage: nil)
            
            Task{
                do{
                    try await chatService.createChat(for: chat)
                    selectChatConversation(conversation)
                    chats.insert(conversation, at: 0)
                }catch{
                    print(error)
                }
            }
        }
    }
}
