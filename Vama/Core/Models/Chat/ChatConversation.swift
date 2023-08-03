//
//  ChatConversation.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation

struct ChatConversation: Identifiable, Hashable{
    
    var id: String{ chat.id }
    let chat: Chat
    var target: ShortUser?
    
}


extension ChatConversation{
    
    static let mocks: [ChatConversation] = Chat.mocks.map({.init(chat: $0, target: .mock)})
    
}
