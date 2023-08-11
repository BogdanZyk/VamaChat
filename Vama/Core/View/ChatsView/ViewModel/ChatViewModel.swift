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
        setupPublishers()
        startChatsListener()
    }
    
    deinit{
        cancelBag.cancel()
        fbListener.cancel()
    }
    
    
    private func setupPublishers(){
        nc.publisher(for: .chatDraftMessage) { notification in
            guard let object = notification.object as? UpdateMessageDraft else { return }
            updateDraft(object)
        }
    }

    private func startChatsListener(){
        guard let currentUID else {return}
        let (pub, listener) = chatService.addChatListener(userId: currentUID)
        
        self.fbListener.listener = listener
        
        pub
            .sink { _ in } receiveValue: { [weak self] listenerData, _ in
                guard let self = self else { return }
                listenerData.forEach { element in
                    self.modifiedChat(chat: element.item, changeType: element.type)
                }
            }
            .store(in: cancelBag)
    }
    
    private func modifiedChat(chat: Chat, changeType: DocumentChangeType){
        switch changeType{
        case .added:
            addedNewChat(chat)
        case .modified:
            updateChatLocal(chat)
        case .removed:
            removeChatLocal(for: chat.id)
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
            pinUnPinChat(for: id)
        case .unpin:
            pinUnPinChat(for: id)
        case .archive:
            print("archive chat")
        case .clear:
            print("Clear chat")
        case .remove:
            removeChat(for: id)
        }
    }
    
    private func removeChat(for id: String){
        Task{
            do{
                try await chatService.deleteChat(for: id)
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    private func pinUnPinChat(for id: String){
        guard let index = chatConversations.firstIndex(where: {$0.id == id}) else {return}
        chatConversations[index].pinned.toggle()
    }
}

//MARK: - Helpers
extension ChatViewModel{
    
    func updateDraft(_ object: UpdateMessageDraft){
        guard let index = chatConversations.firstIndex(where: {$0.id == object.chatId}) else {return}
        chatConversations[index].draftMessage = object.message
    }
    
    private func removeChatLocal(for id: String){
        chatConversations.removeAll(where: {$0.id == id})
    }
    
    private func updateChatLocal(_ chat: Chat){
        guard let index = chatConversations.firstIndex(where: {$0.id == chat.id}) else {return}
        chatConversations[index].chat = chat
    }
    
    private func addedNewChat(_ chat: Chat){
        guard let currentUID, !chatConversations.contains(where: {$0.id == chat.id}) else {return}
        Task{
            guard let chatConversation = try await createChatConversation(currentUID: currentUID, chat: chat) else {return}
            chatConversations.append(chatConversation)
            chatConversations.sort(by: {sortChat(lh: $0, rh: $1)})
        }
    }
    
    private func sortChat(lh: ChatConversation, rh: ChatConversation) -> Bool{
        (lh.chat.lastMessage?.createdAt.date ?? lh.chat.createdAt.date) > (rh.chat.lastMessage?.createdAt.date ?? rh.chat.createdAt.date)
    }
    
}
