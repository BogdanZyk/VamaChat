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
        messages.insert(.init(message: message), at: 0)
        sendCounter += 1
        textMessage = ""
    }
}


struct DialogMessage: Identifiable{
    var id: String{ message.id }
    let message: Message
    let loadState: LoadState = .sending
    
    enum LoadState {
        case sending, completed, error
    }
}
