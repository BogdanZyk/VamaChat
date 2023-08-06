//
//  Message.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation

struct Message: Identifiable, Hashable{
    
    let id: String
    let chatId: String
    let message: String?
    let sender: ShortUser
    let createdAt = FBTimestamp()
    var replies: [Message] = []
    var media: [MessageMedia] = []
    var pinned: Bool = false
    var viewedIds: [String] = []
    
    func getRecipientType(currentUserId: String?) -> RecipientType{
        sender.id == currentUserId ? .sent : .received
    }
}

extension Message{
    static let mocks: [Message] = [
        .init(id: UUID().uuidString, chatId: "1", message: "Hello!", sender: .mock),
        .init(id: UUID().uuidString, chatId: "1", message: "Hi!", sender: .mock)
    ]
}


extension Message: Codable{
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId
        case message
        case sender
        case createdAt
        case viewedIds
        case media
        case pinned
    }
}




