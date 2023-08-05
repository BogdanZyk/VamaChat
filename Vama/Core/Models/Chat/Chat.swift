//
//  Chat.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation
import FirebaseFirestore

struct Chat: Identifiable, Codable{
    let id: String
    let chatType: ChatType
    let lastMessage: Message?
    var dialogStatus = Status()
    var title: String?
    var photo: String?
    let participantsIds: [String]
    let createdAt = FBTimestamp()
   

    
    enum CodingKeys: String, CodingKey {
        case id
        case chatType
        case lastMessage
        case participantsIds
        case createdAt
        case title
        case photo
        case dialogStatus
    }
}

extension Chat{
    enum ChatType: String, Codable{
        case chatPrivate = "PRIVATE"
        case chatGroup = "GROUP"
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

extension Chat{
    
    struct Status: Codable, Hashable{
        
        var fromId: String = ""
        var status: Status = .empty
        
        enum Status: String, Codable{
            case typing = "TYPING"
            case empty = "EMPTY"
            case upload = "UPLOAD"
        }
    }
}

