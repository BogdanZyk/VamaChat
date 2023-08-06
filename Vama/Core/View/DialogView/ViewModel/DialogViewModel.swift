//
//  DialogViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation
import Algorithms
import FirebaseFirestore

class DialogViewModel: ObservableObject{
    
    @Published private(set) var messages: [DialogMessage] = []
    @Published private(set) var bottomBarActionType: BottomBarActionType = .empty
    @Published private(set) var selectedMessages: [Message] = []
    @Published private(set) var pinnedMessages: [Message] = []
    @Published var showFileExporter: Bool = false
    @Published var textMessage: String = ""
    @Published var pinMessageTrigger: Bool = false
    
    private let pasteboard = NSPasteboard.general
    private let messageService = MessageService.shared
    private let userService = UserService.share
    private(set) var targetMessageId: String?
    private var cancelBag = CancelBag()
    private var fbListeners: [FBListener] = []
    private var totalCountMessage: Int = 0
    private var lastDoc = FBLastDoc()
    private var sending: Bool = false

    
    var chatData: ChatConversation
    var currentUser: User?
    
    init(chatData: ChatConversation, currentUser: User?) {
        self.chatData = chatData
        self.currentUser = currentUser
        fetchMessages(chatData.id)
        startMessageListener(chatData.id)
        startPinMessagesListener()
    }
    
    deinit{
        fbListeners.forEach({$0.cancel()})
        cancelBag.cancel()
    }
    
    @MainActor
    func send(){
        guard let currentUser else {return}
        print("Send message \(textMessage)")
        let message = Message(id: UUID().uuidString, chatId: chatData.id, message: textMessage, sender: currentUser.getShortUser())
        messages.insert(.init(message: message, loadState: .sending), at: 0)
        targetMessageId = message.id
        textMessage = ""
        resetBottomBarAction()
        sending = true
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
        startMessageListener(chatData.id)
        startPinMessagesListener()
    }
    
    private func fetchMessages(_ chatId: String){
        Task{
            let total = try await messageService.getCountAllMessages(chatId: chatId)
            let (messages, lastDoc) = try await messageService.fetchPaginatedMessage(for: chatId, lastDocument: lastDoc.lastDocument)
            await MainActor.run {
                self.totalCountMessage = total
                self.lastDoc.lastDocument = lastDoc
                let dialogMessages = messages.map({DialogMessage(message: $0)})
                self.messages.append(contentsOf: dialogMessages)
            }
        }
    }
    
    func viewMessage(_ id: String){
        
    }
    
    func loadNextPage(_ id: String){
        
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
                sending = false
            }catch{
                print(error.localizedDescription)
                changeMessageUploadStatus(for: message.id, status: .error)
                sending = false
            }
        }
    }
    
    private func startMessageListener(_ chatId: String){
        
        let (publisher, listener) = messageService.addListenerForMessages(chatId: chatId)
        let fbListener = FBListener(listener: listener)
        fbListeners.append(fbListener)
        
        publisher.sink { completion in
            switch completion{
                
            case .finished: break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: {[weak self] dataDict in
            guard let self = self, let element = dataDict.first else {return}
        
            self.modifiedDialog(message: element.key, changeType: element.value)
            
        }
        .store(in: cancelBag)
    }
    
    private func modifiedDialog(message: Message, changeType: DocumentChangeType){
        switch changeType{
            
        case .added:
            print("added")
            addMessage(message)
        case .modified:
            print("modified")
            modifiedMessage(message)
        case .removed:
            print("removed")
            if !sending{
                removeMessageLocal(message.id)
            }
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
            try await messageService.removeMessage(for: chatData.id, message: message, lastMessage: messages.first?.message)
            await MainActor.run {
                removeMessageLocal(message.id)
            }
        }
    }
}

extension DialogViewModel{
    
    enum BottomBarActionType{
        case edit(Message), answer(Message), empty
        
        var id: Int{
            switch self{
            case .edit: return 0
            case .answer: return 1
            case .empty: return 2
            }
        }
        
        var message: Message?{
            switch self{
            case .edit(let message): return message
            case .answer(let message): return message
            case .empty: return nil
            }
        }
    }
    
    private func setBottomBarAction(_ bottomBarActionType: BottomBarActionType){
        self.bottomBarActionType = bottomBarActionType
    }
    
    func resetBottomBarAction(){
        bottomBarActionType = .empty
    }
    
}

//MARK: - Pin onTapPinMessagemessage logic
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

