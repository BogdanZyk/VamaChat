//
//  Chat.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation


struct Chat: Identifiable, Codable{
    let id: String
    let chatType: ChatType
    let lastMessage: Message?
    var title: String?
    var photo: String?
    let participantsIds: [String]
    let createdAt: Date = Date()

    
    enum CodingKeys: String, CodingKey {
        case id
        case chatType
        case lastMessage
        case participantsIds
        case createdAt
        case title
        case photo
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
        .init(id: UUID().uuidString, chatType: .chatPrivate, lastMessage: Message.mocks.first, participantsIds: [User.mock.id, "1"]),
        .init(id: UUID().uuidString, chatType: .chatPrivate, lastMessage: Message.mocks.first, participantsIds: []),
        .init(id: UUID().uuidString, chatType: .chatPrivate, lastMessage: Message.mocks.first, participantsIds: [])
    ]
}

