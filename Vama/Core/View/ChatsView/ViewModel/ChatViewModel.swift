//
//  ChatViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation
import FirebaseFirestore

@MainActor
final class ChatViewModel: ObservableObject{
    
    @Published var chatConversations: [ChatConversation] = []
    @Published var selectedChat: ChatConversation?
    private let userService = UserService.share
    private let chatService = ChatServices.shared
    private var cancelBag = CancelBag()
    private var fbListener = FBListener()
    
    var currentUID: String?{
        userService.getFBUserId()
    }
    
    init(){
        startChatsListener()
    }
    
    deinit{
        cancelBag.cancel()
        fbListener.cancel()
    }

   private func startChatsListener(){
        guard let currentUID else {return}
        let (pub, listener) = chatService.addChatListener(userId: currentUID)


        self.fbListener.listener = listener

        pub
            .sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] dataDict in
                guard let self = self else { return }
                dataDict.forEach { element in
                    self.modifiedChat(chat: element.key, changeType: element.value)
                }
            }
            .store(in: cancelBag)
    }
    
    private func modifiedChat(chat: Chat, changeType: DocumentChangeType){
        switch changeType{
        case .added:
            addNewChat(chat)
        case .modified:
            updateChatLocal(chat)
        case .removed:
            removeChatLocal(for: chat.id)
        }
    }
    
    private func removeChatLocal(for id: String){
        chatConversations.removeAll(where: {$0.id == id})
    }
    
    private func updateChatLocal(_ chat: Chat){
        guard let index = chatConversations.firstIndex(where: {$0.id == chat.id}) else {return}
        chatConversations[index].chat = chat
    }
    
    private func addNewChat(_ chat: Chat){
        guard let currentUID, !chatConversations.contains(where: {$0.id == chat.id}) else {return}
        Task{
            guard let chatConversation = try await createChatConversation(currentUID: currentUID, chat: chat) else {return}
            await MainActor.run {
                self.chatConversations.append(chatConversation)
            }
        }
    }
    
}

//MARK: - Chat conversation logic

extension ChatViewModel{
    
    func selectChatConversation(_ chat: ChatConversation){
        selectedChat = chat
    }
    
    func createChatConversation(for target: ShortUser){
        
        guard let currentUID, currentUID != target.id else {return}
        
        if let existConversation = chatConversations.first(where: {$0.target?.id == target.id}){
            selectChatConversation(existConversation)
        }else{
            let chat = Chat(id: UUID().uuidString, chatType: .chatPrivate, lastMessage: nil, participantsIds: [currentUID, target.id])
            let conversation = ChatConversation(chat: chat, target: target, draftMessage: nil)
            
            Task{
                do{
                    try await chatService.createChat(for: chat)
                    selectChatConversation(conversation)
                    chatConversations.insert(conversation, at: 0)
                }catch{
                    print(error)
                }
            }
        }
    }
    
    private func createChatConversation(currentUID: String, chat: Chat) async throws -> ChatConversation?{
        guard let participantId = chat.participantsIds.first(where: {$0 != currentUID}) else {return nil}
        let user = try await userService.getUser(for: participantId)
        
        if chat.participantsIds.contains(user.id){
            return ChatConversation(chat: chat, target: ShortUser(user: user))
        }
        
        return nil
    }
}

//MARK: - Chat actions
extension ChatViewModel{
    
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

//MARK: - Helpers
extension ChatViewModel{
    
    func onSetDraft(_ draftText: String?, id: String){
        guard let index = chatConversations.firstIndex(where: {$0.id == id}) else {return}
        chatConversations[index].draftMessage = draftText
    }
    
}
