//
//  Conversation.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation


struct Chat: Identifiable, Codable{
    let id: String
    let chatType: ChatType
    let title: String
    let photo: String
    let lastMessage: Message?
    let participantsIds: [String]
    let createdAt: Date = Date()
    var unreadCount: Int = 0
    var pinned: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatType
        case title
        case photo
        case lastMessage
        case participantsIds
        case createdAt
        case unreadCount
        case pinned
    }
}

extension Chat{
    enum ChatType: Codable{
        case chatPrivate, chatGroup
    }
}

extension Chat: Hashable{
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }
}

extension Chat{
    
    static let mocks: [Chat] = [
        .init(id: UUID().uuidString, chatType: .chatPrivate, title: ShortUser.mock.name, photo: ShortUser.mock.image!, lastMessage: Message.mocks.first, participantsIds: []),
        .init(id: UUID().uuidString, chatType: .chatPrivate, title: ShortUser.mock.name, photo: ShortUser.mock.image!, lastMessage: Message.mocks.first, participantsIds: []),
        .init(id: UUID().uuidString, chatType: .chatPrivate, title: ShortUser.mock.name, photo: ShortUser.mock.image!, lastMessage: Message.mocks.first, participantsIds: [])
    ]
      
}


