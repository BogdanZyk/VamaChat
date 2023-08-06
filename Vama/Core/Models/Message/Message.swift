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
    var message: String?
    let fromId: String
    let createdAt = FBTimestamp()
    var replies: [Message] = []
    var media: [MessageMedia] = []
    var pinned: Bool = false
    var viewedIds: [String] = []
    
}

extension Message{
    
    func getRecipientType(currentUserId: String?) -> RecipientType{
        fromId == currentUserId ? .sent : .received
    }
    
    func viewMessage(for userId: String) -> Bool{
        viewedIds.contains(userId)
    }
    
    func viewAllExceptSender() -> Bool{
        let usersIds = viewedIds.dropFirst()
        return usersIds.isEmpty ? false : viewedIds.contains(usersIds)
    }
}

extension Message{
    static let mocks: [Message] = [
        .init(id: UUID().uuidString, chatId: "1", message: "Hello!", fromId: "1"),
        .init(id: UUID().uuidString, chatId: "1", message: "Hi!", fromId: "2")
    ]
}


extension Message: Codable{
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId
        case message
        case fromId
        case createdAt
        case viewedIds
        case media
        case pinned
    }
}




