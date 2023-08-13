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
import Combine

class DialogViewModel: ObservableObject {
    
    @Published var bottomBarActionType: BottomBarActionType = .empty
    @Published var showFileExporter: Bool = false
    @Published var textMessage: String = ""
    @Published var pinMessageTrigger: Bool = false
    @Published var onAppear: Bool = false
    
    @Published private(set) var messages: [DialogMessage] = []
    @Published private(set) var isActiveSelectedMode: Bool = false
    @Published private(set) var pinnedMessages: [Message] = []
    
    private let pasteboard = NSPasteboard.general
    private let messageService = MessageService.shared
    private let chatService = ChatServices.shared
    private let userService = UserService.share
    private(set) var targetMessageId: String?
    private var cancelBag = CancelBag()
    private var fbListeners: [FBListener] = []
    private var totalCountMessage: Int = 0
    private var lastDoc = FBLastDoc()
    private var setupCancellable: AnyCancellable?
    
    var chatData: ChatConversation
    var currentUser: User?
    
    init(chatData: ChatConversation, currentUser: User?) {
        self.chatData = chatData
        self.currentUser = currentUser
        setupAppearPublisher()
    }
    
    deinit {
        setupCancellable?.cancel()
        cancelAll()
    }
    
    private func setupAppearPublisher() {
        setupCancellable = $onAppear
            .sink {[weak self] onAppear in
                guard let self = self else {return}
                if onAppear{
                    self.setupDialog()
                }else{
                    self.setDraft()
                    self.cancelAll()
                }
            }
    }
    
    private func setupPublishers() {
        $textMessage
            .debounce(for: 2, scheduler: DispatchQueue.main)
            .sink {[weak self] text in
                guard let self = self else {return}
                self.setDraft(remove: true)
                self.updateChatAction()
            }
            .store(in: cancelBag)
    }
    
    private func setupDialog() {
        setupPublishers()
        startMessageListener()
        startPinMessagesListener()
        fetchTotalCountMessages()
    }
    
    private func cancelAll() {
        fbListeners.forEach({$0.cancel()})
        cancelBag.cancel()
    }
}


// MARK: - Message send action
extension DialogViewModel {
    
    @MainActor
    func send() {
        switch bottomBarActionType {
        case .reply(let message):
            sendReplyMessage(message)
        case .edit(let message):
            updateMessage(message: message, text: textMessage)
        case .empty:
            sendMessage()
        }
        textMessage = ""
        resetBottomBarAction()
    }
    
    @MainActor
    private func sendMessage(replyMessage: [SubMessage]? = nil) {
        guard let currentUser else {return}
        print("Send message \(textMessage)")
        
        let message = Message(id: UUID().uuidString,
                              chatId: chatData.id,
                              message: textMessage,
                              fromId: currentUser.id,
                              replyMessage: replyMessage,
                              media: [.init(type: .image, path: "https://www.onlygfx.com/wp-content/uploads/2017/06/pine-tree-silhouette-2-176x300.png")],
                              viewedIds: [currentUser.id])
        
        messages.insert(.init(message: message, loadState: .sending), at: 0)
        targetMessageId = message.id
        uploadMessage(chatId: chatData.id, message: message)
    }
    
    @MainActor
    private func sendReplyMessage(_ message: Message) {
        guard let user = getMessageSender(senderId: message.fromId) else {return}
        
        var subMessage: SubMessage
        
        if let forward = message.forwardMessages?.first{
            var newMessage = message
            newMessage.message = forward.message.message ?? ""
            subMessage = SubMessage(message: newMessage, user: .init(id: user.id, fullName: user.fullName))
        }else{
            subMessage = SubMessage(message: message, user: .init(id: user.id, fullName: user.fullName))
        }
        
        sendMessage(replyMessage: [subMessage])
    }
    
    @MainActor
    private func forwardMessages(_ messages: [Message], for chatId: String) {
        guard let currentUser, let forwardMessages = createSubMessages(messages) else {return}
        
        forwardMessages.forEach({ forwardMessage in
            let message = Message(id: UUID().uuidString,
                                  chatId: chatId,
                                  message: nil,
                                  fromId: currentUser.id,
                                  forwardMessages: [forwardMessage],
                                  viewedIds: [currentUser.id])
            
            uploadMessage(chatId: chatData.id, message: message)
            
            if chatId == chatData.id{
                self.messages.insert(.init(message: message, loadState: .sending), at: 0)
            }
        })
    }
}

// MARK: - Helpers
extension DialogViewModel {

    func loadNextPage(_ messageId: String) {
        if shouldNextPageLoader(messageId) {
            withAnimation {
                fetchMessages(chatData.id)
            }
        }
    }
    
    func getDialogActionStr() -> String{
        if let action = chatData.chat.action, action.status != .empty, action.fromId != currentUser?.id{
           return action.status.title
        }else{
            return chatData.target?.status.statusStr ?? ""
        }
    }
    
    private func shouldNextPageLoader(_ messageId: String) -> Bool {
        (messages.last?.id == messageId) && totalCountMessage > messages.count
    }
    
    func getMessageSender(senderId: String) -> ShortUser? {
        let users = [currentUser?.getShortUser(), chatData.target]
        return users.first(where: {$0?.id == senderId}) ?? nil
    }
    
    private func createSubMessages(_ messages: [Message]) -> [SubMessage]? {
        return messages.compactMap { message in
            guard let user = getMessageSender(senderId: message.fromId) else {return nil}
            return SubMessage(message: message, user: .init(id: user.id, fullName: user.fullName))
        }
    }
}

// MARK: - Message service get, update and listener
extension DialogViewModel {
    
    private func fetchMessages(_ chatId: String) {
        Task{
            let (messages, lastDoc) = try await messageService.fetchPaginatedMessage(for: chatId, lastDocument: lastDoc.lastDocument)
            Task.main {
                self.lastDoc.lastDocument = lastDoc
                let dialogMessages = messages.map({DialogMessage(message: $0)})
                self.messages.append(contentsOf: dialogMessages)
            }
        }
    }
    
    private func fetchTotalCountMessages() {
        Task{
            let total = try await messageService.getCountAllMessages(chatId: chatData.id)
            Task.main {
                print("Total message", total)
                self.totalCountMessage = total
            }
        }
    }
    
    @MainActor
    private func uploadMessage(chatId: String, message: Message) {
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
    
    @MainActor
    private func updateMessage(message: Message, text: String) {
        Task{
            var mess = message
            mess.message = text
            let isUpdateLastMessage = message.id == messages.first?.id
            try await messageService.updateMessage(for: chatData.id, message: mess, isUpdateLastMessage: isUpdateLastMessage)
            guard let index = messages.firstIndex(where: {$0.id == message.id}) else {return}
            messages[index].message = mess
        }
    }
    
    private func startMessageListener() {
        
        let (publisher, listener) = messageService.addListenerForMessages(chatId: chatData.id)
        let fbListener = FBListener(listener: listener)
        fbListeners.append(fbListener)
        
        publisher.sink { completion in
            switch completion{
                
            case .finished: break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: {[weak self] listenerData, lastDoc in
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
    
    func viewMessage(_ message: Message) {
        guard let uid = currentUser?.id, message.fromId != uid else {return}
        if message.viewedIds.contains(uid){return}
        Task {
            try await messageService.viewMessage(for: chatData.id, messageId: message.id, uid: uid)
        }
    }

    private func modifiedDialog(message: Message, changeType: DocumentChangeType) {
        switch changeType {
            
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
    
    private func updateChatAction(){
        guard let id = currentUser?.id else {return}
        let isTyping = !textMessage.isEmpty
        Task{
            try await chatService.updateChatAction(
                for: chatData.id,
                action: .init(fromId: id, status: isTyping ? .typing : .empty))
        }
    }
}

//MARK: - Message actions
extension DialogViewModel {
    
    @MainActor func messageAction(_ action: MessageContextAction, _ message: Message) {
        switch action {
        case .answer:
            setBottomBarAction(.reply(message))
        case .edit:
            setBottomBarAction(.edit(message))
        case .copy:
            copyMessage(message: message.message)
        case .pin:
            pinOrUnpinMessage(message: message, onPinned: true)
        case .unpin:
            pinOrUnpinMessage(message: message, onPinned: false)
        case .forward:
            forwardMessages([message], for: chatData.id)
        case .select:
            toggleSelectedMessage(for: message.id)
        case .remove:
            removeMessage(message)
        }
    }
    
    private func copyMessage(message: String?) {
        guard let message else {return}
        pasteboard.clearContents()
        pasteboard.setString(message, forType: .string)
    }
    
    private func removeMessage(_ message: Message) {
        Task{
            
            var lastMessage: Message?
            
            if messages.count >= 2, message.id == messages.first?.id{
                lastMessage = messages[1].message
            }
            
            try await messageService.removeMessage(for: chatData.id, message: message, lastMessage: lastMessage)
            Task.main {
                removeMessageLocal(message.id)
            }
        }
    }
        
    private func addMessage(_ message: Message) {
        if messages.first(where: {$0.id == message.id}) == nil {
            messages.insert(.init(message: message), at: 0)
            totalCountMessage += 1
            messages = messages.uniqued(on: {$0.id})
            targetMessageId = message.id
        }
    }
    
    private func modifiedMessage(_ message: Message) {
        guard let index = messages.firstIndex(where: {$0.id == message.id}) else {return}
        self.messages[index] = .init(message: message)
    }
    
    private func removeMessageLocal(_ messageId: String) {
        messages.removeAll(where: {$0.id == messageId})
        self.totalCountMessage -= 1
    }
    
    private func changeMessageUploadStatus(for id: String, status: DialogMessage.LoadState) {
        guard let index = messages.firstIndex(where: {$0.id == id}) else {return}
        messages[index].changeStatus(status)
    }
    
    private func setDraft(remove: Bool = false) {
        let message = remove ? nil :
        (textMessage.isEmpty && textMessage.isEmptyStrWithSpace ? nil : textMessage)
        let object = UpdateMessageDraft(chatId: chatData.id, message: message)
        nc.post(name: .chatDraftMessage, object: object)
    }
}


//MARK: - Pin message logic
extension DialogViewModel {
    
    func onTapPinMessage() {
        pinMessageTrigger.toggle()
    }
    
    func pinOrUnpinMessage(message: Message, onPinned: Bool) {
        Task{
            if onPinned {
                try await messageService.pinMessage(for:chatData.id, message: message)
            } else {
                try await messageService.unpinMessage(for: chatData.id, messageId: message.id)
            }
        }
        updatePinLocal(messageId: message.id, onPinned: onPinned)
    }
    
    private func updatePinLocal(messageId: String, onPinned: Bool) {
        guard let index = messages.firstIndex(where: {$0.id == messageId}) else {return}
        messages[index].message.pinned = onPinned
    }
    
    private func startPinMessagesListener() {
        
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

// MARK: - Selected message logic
extension DialogViewModel {
    
    private func toggleSelectedMessage(for id: String){
        guard let index = messages.lastIndex(where: {$0.id == id}) else {return}
        messages[index].selected.toggle()
        isActiveSelectedMode = messages.contains(where: {$0.selected})
    }
    
    private func resetSelection(){
        for item in messages.enumerated(){
            messages[item.offset].selected = false
        }
        isActiveSelectedMode = false
    }
}


struct DialogMessage: Identifiable {
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

struct UpdateMessageDraft{
    var chatId: String
    var message: String?
}
