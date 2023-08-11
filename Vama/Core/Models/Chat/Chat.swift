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
    let participantsIds: [String]
    var createdAt = FBTimestamp()
    var title: String?
    var photo: String?
    var action: ChatAction?
   
    enum CodingKeys: String, CodingKey {
        case id
        case chatType
        case lastMessage
        case participantsIds
        case createdAt
        case title
        case photo
        case action
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

struct ChatAction: Codable, Hashable{
    
    var fromId: String = ""
    var status: Status = .empty
    
    enum Status: String, Codable{
        case typing
        case empty
        case upload
        
        var title: String{
            switch self{
            case .typing:
                return "typing..."
            case .upload:
                return "uploading photo..."
            case .empty:
                return ""
            }
        }
    }
}
