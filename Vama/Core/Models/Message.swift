//
//  Message.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation

struct Message: Identifiable, Codable{
    let id: String
    let chatId: String
    var text: String
    var senderId: String
    var recipientId: String
    var viewed: Bool? = false
    var createdAt: Date = Date()
    var imagesPaths: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId
        case text
        case senderId
        case recipientId
        case createdAt
        case viewed
        case imagesPaths
    }
    
    func getRecipientType(currentUserId: String?) -> RecipientType{
        senderId == currentUserId ? .sent : .received
    }
}

extension Message{
    static let mocks: [Message] = [
        .init(id: UUID().uuidString, chatId: "1", text: "Hello!", senderId: "1", recipientId: "2"),
        .init(id: UUID().uuidString, chatId: "1", text: "Hi!", senderId: "2", recipientId: "1")
    ]
}
