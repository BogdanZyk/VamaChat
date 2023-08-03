//
//  DialogViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation
import Algorithms

class DialogViewModel: ObservableObject{
    
    @Published private(set) var messages: [DialogMessage] = []
    @Published private(set) var bottomBarActionType: BottomBarActionType = .empty
    @Published private(set) var selectedMessages: [Message] = []
    
    @Published var showFileExporter: Bool = false
    @Published var textMessage: String = ""
    @Published var sendCounter: Int = 0
    
    let chatId: String
    
    
    init(chatId: String) {
        self.chatId = chatId
        fetchMessages()
    }
    
    private func fetchMessages(){
        print("fetch messages \(chatId)")
        
        self.messages = Message.mocks.map({.init(message: $0)})
        
    }
    
    
    func viewMessage(_ id: String){
        
    }
    
    func loadNextPage(_ id: String){
        
    }
    
    func send(){
        print("Send message \(textMessage)")
        let message = Message(id: UUID().uuidString, chatId: "1", message: textMessage, sender: .mock)
        messages.insert(.init(message: message, loadState: .sending), at: 0)
        sendCounter += 1
        textMessage = ""
        resetBottomBarAction()
        updateLoaderMessageState()
    }
    
    func updateLoaderMessageState(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.messages[0].loadState = .completed
        }
    }
    
    func messageAction(_ action: MessageContextAction, _ message: Message){
        switch action {
        case .answer:
            setBottomBarAction(.answer(message))
        case .edit:
            setBottomBarAction(.edit(message))
        case .copy:
            print("Copy \(message.message ?? "")")
        case .pin:
            print("Pin \(message.message ?? "")")
        case .forward:
            print("Forward \(message.message ?? "")")
        case .select:
            print("Select \(message.message ?? "")")
        case .remove:
            print("Remove \(message.message ?? "")")
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



struct DialogMessage: Identifiable{
    var id: String{ message.id }
    let message: Message
    var loadState: LoadState = .completed
    var selected: Bool = false
    
    enum LoadState {
        case sending, completed, error
    }
}

