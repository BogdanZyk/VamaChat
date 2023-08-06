//
//  DialogViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation
import Algorithms
import FirebaseFirestore
import SwiftUI

class DialogViewModel: ObservableObject{
    
    @Published var bottomBarActionType: BottomBarActionType = .empty
    @Published var showFileExporter: Bool = false
    @Published var textMessage: String = ""
    @Published var pinMessageTrigger: Bool = false
    
    @Published private(set) var messages: [DialogMessage] = []
    @Published private(set) var selectedMessages: [Message] = []
    @Published private(set) var pinnedMessages: [Message] = []
    
    private let pasteboard = NSPasteboard.general
    private let messageService = MessageService.shared
    private let userService = UserService.share
    private(set) var targetMessageId: String?
    private var cancelBag = CancelBag()
    private var fbListeners: [FBListener] = []
    private var totalCountMessage: Int = 0
    private var lastDoc = FBLastDoc()


    
    var chatData: ChatConversation
    var currentUser: User?
    
    init(chatData: ChatConversation, currentUser: User?) {
        self.chatData = chatData
        self.currentUser = currentUser
        startMessageListener()
        startPinMessagesListener()
        fetchTotalCountMessages()
    }
    
    deinit{
        fbListeners.forEach({$0.cancel()})
        cancelBag.cancel()
    }
    
    @MainActor
    func send(){
        switch bottomBarActionType{
        case .answer(_):
            print("send answer message")
        case .edit(let message):
            updateMessage(message: message, text: textMessage)
        case .empty:
            sendMessage()
        }
        textMessage = ""
        resetBottomBarAction()
    }
    
    @MainActor
    private func sendMessage(){
        guard let currentUser else {return}
        print("Send message \(textMessage)")
        let message = Message(id: UUID().uuidString, chatId: chatData.id, message: textMessage, fromId: currentUser.id, viewedIds: [currentUser.id])
        messages.insert(.init(message: message, loadState: .sending), at: 0)
        targetMessageId = message.id
        uploadMessage(chatId: chatData.id, message: message)
    }
    
  
    func setChatDataAndRefetch(chatData: ChatConversation){
        fbListeners.forEach({$0.cancel()})
        bottomBarActionType = .empty
        textMessage = chatData.draftMessage ?? ""
        self.chatData = chatData
        lastDoc = FBLastDoc()
        messages = []
        selectedMessages = []
        fetchMessages(chatData.id)
        startMessageListener()
        startPinMessagesListener()
        fetchTotalCountMessages()
    }
    
    private func fetchMessages(_ chatId: String){
        Task{
            let (messages, lastDoc) = try await messageService.fetchPaginatedMessage(for: chatId, lastDocument: lastDoc.lastDocument)
            await MainActor.run {
                self.lastDoc.lastDocument = lastDoc
                let dialogMessages = messages.map({DialogMessage(message: $0)})
                self.messages.append(contentsOf: dialogMessages)
            }
        }
    }
    
    private func fetchTotalCountMessages(){
        Task{
            let total = try await messageService.getCountAllMessages(chatId: chatData.id)
            await MainActor.run {
                print("Total message", total)
                self.totalCountMessage = total
            }
        }
    }
    
    func viewMessage(_ message: Message){
        guard let uid = currentUser?.id, message.fromId != uid else {return}
        Task{
            print("viewMessage")
            try await messageService.viewMessage(for: chatData.id, message: message, uid: uid)
        }
    }
    
    func getMessageSender(senderId: String) -> ShortUser?{
        let users = [currentUser?.getShortUser(), chatData.target]
        return users.first(where: {$0?.id == senderId}) ?? nil
    }
}

extension DialogViewModel{
    
    private func shouldNextPageLoader(_ messageId: String) -> Bool{
        (messages.last?.id == messageId) && totalCountMessage > messages.count
    }
    
    func loadNextPage(_ messageId: String){
        if shouldNextPageLoader(messageId){
            withAnimation {
                print("loadNextPage")
                fetchMessages(chatData.id)
            }
        }
    }
}


extension DialogViewModel{
    
    @MainActor
    private func uploadMessage(chatId: String, message: Message){
        Task{
            do{
                try await messageService.sendMessage(for: chatData.id, message: message)
                totalCountMessage += 1
                changeMessageUploadStatus(for: message.id, status: .completed)
            }catch{
                print(error.localizedDescription)
                changeMessageUploadStatus(for: message.id, status: .error)
            }
        }
    }
    
    private func startMessageListener(){
        
        let (publisher, listener, lastDoc) = messageService.addListenerForMessages(chatId: chatData.id)
        let fbListener = FBListener(listener: listener)
        fbListeners.append(fbListener)
        
        publisher.sink { completion in
            switch completion{
                
            case .finished: break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: {[weak self] listenerData in
            guard let self = self, let element = listenerData.last else {return}
            /// set messages by default
            if messages.isEmpty, self.lastDoc.lastDocument == nil{
                self.lastDoc.lastDocument = lastDoc
                let messages = listenerData.compactMap({DialogMessage(message: $0.item)})
                self.messages = messages
            }else{
                self.modifiedDialog(message: element.item, changeType: element.type)
            }
           
        }
        .store(in: cancelBag)
    }
    
    private func modifiedDialog(message: Message, changeType: DocumentChangeType){
        switch changeType{
            
        case .added:
            print("Added new message", message.id)
            addMessage(message)
        case .modified:
            print("Modified message", message.id)
            modifiedMessage(message)
        case .removed:
            print("Remove", message.id)
            removeMessageLocal(message.id)
        }
    }
    
    private func addMessage(_ message: Message){
        if messages.first(where: {$0.id == message.id}) == nil{
            messages.insert(.init(message: message), at: 0)
            totalCountMessage += 1
            messages = messages.uniqued(on: {$0.id})
            targetMessageId = message.id
        }
    }
    
    private func modifiedMessage(_ message: Message){
        guard let index = messages.firstIndex(where: {$0.id == message.id}) else {return}
        self.messages[index] = .init(message: message)
    }
    
    private func removeMessageLocal(_ messageId: String){
        messages.removeAll(where: {$0.id == messageId})
        self.totalCountMessage -= 1
    }
    
    private func changeMessageUploadStatus(for id: String, status: DialogMessage.LoadState){
        guard let index = messages.firstIndex(where: {$0.id == id}) else {return}
        messages[index].changeStatus(status)
    }
    
}

//MARK: - Message action
extension DialogViewModel{
    
    @MainActor func messageAction(_ action: MessageContextAction, _ message: Message){
        switch action {
        case .answer:
            setBottomBarAction(.answer(message))
        case .edit:
            setBottomBarAction(.edit(message))
        case .copy:
            copyMessage(message: message.message)
        case .pin:
            pinOrUnpinMessage(message: message, onPinned: true)
        case .unpin:
            pinOrUnpinMessage(message: message, onPinned: false)
        case .forward:
            print("Forward \(message.message ?? "")")
        case .select:
            print("Select \(message.message ?? "")")
        case .remove:
            removeMessage(message)
        }
    }
    
    private func copyMessage(message: String?){
        guard let message else {return}
        pasteboard.clearContents()
        pasteboard.setString(message, forType: .string)
    }
    
    private func removeMessage(_ message: Message){
        Task{
            
            var lastMessage: Message?
            
            if messages.count >= 2, message.id == messages.first?.id{
                lastMessage = messages[1].message
            }
            
            try await messageService.removeMessage(for: chatData.id, message: message, lastMessage: lastMessage)
            await MainActor.run {
                removeMessageLocal(message.id)
            }
        }
    }
}



//MARK: - Edit message logic
extension DialogViewModel{
    
    @MainActor
    private func updateMessage(message: Message, text: String){
        Task{
            var mess = message
            mess.message = text
            let isUpdateLastMessage = message.id == messages.first?.id
            try await messageService.updateMessage(for: chatData.id, message: mess, isUpdateLastMessage: isUpdateLastMessage)
//            guard let index = messages.firstIndex(where: {$0.id == message.id}) else {return}
//            messages[index].message = mess
        }
    }
    
}

//MARK: - Pin message logic
extension DialogViewModel{
    
    func onTapPinMessage(){
        pinMessageTrigger.toggle()
    }
    
    func pinOrUnpinMessage(message: Message, onPinned: Bool){
        Task{
            if onPinned{
                try await messageService.pinMessage(for:chatData.id, message: message)
            }else{
                try await messageService.unpinMessage(for: chatData.id, messageId: message.id)
            }
        }
        updatePinLocal(messageId: message.id, onPinned: onPinned)
    }
    
    private func updatePinLocal(messageId: String, onPinned: Bool){
        guard let index = messages.firstIndex(where: {$0.id == messageId}) else {return}
        messages[index].message.pinned = onPinned
    }
    
    private func startPinMessagesListener(){
        
        let res = messageService.addListenerForPinMessages(chatId: chatData.id)
        
        let fbListener = FBListener(listener: res.listener)
        fbListeners.append(fbListener)
        
        res.publisher.sink { completion in
            switch completion{
                
            case .finished: break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: {[weak self] messages in
            guard let self = self else {return}
            self.pinnedMessages = messages
        }
        .store(in: cancelBag)
    }
}



struct DialogMessage: Identifiable{
    var id: String{ message.id }
    var message: Message
    var loadState: LoadState = .completed
    var selected: Bool = false
    
    enum LoadState {
        case sending, completed, error
    }
    
    mutating func changeStatus(_ loadState: LoadState){
        self.loadState = loadState
    }
}

