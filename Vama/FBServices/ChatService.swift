//
//  ChatService.swift
//  Vama
//
//  Created by Bogdan Zykov on 05.08.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine


final class ChatServices{
    
    private init(){}
    
    static let shared = ChatServices()
    
    private let chatsCollections = FbFirestoreService.shared.db.collection("chats")
    
    func getChatDocument(for id: String) -> DocumentReference{
        chatsCollections.document(id)
    }
    
    func createChat(for chat: Chat) async throws{
        try chatsCollections.document(chat.id).setData(from: chat, merge: true)
    }
    
    func getChat(for id: String) async throws -> Chat{
        try await getChatDocument(for: id).getDocument(as: Chat.self)
    }
    
    func updateLastChatMessage(for id: String, shortMessage: Message) async throws{
        
        let data = try Firestore.Encoder().encode(shortMessage)
        
        let dict: [String: Any] = [
            Chat.CodingKeys.lastMessage.rawValue: data
        ]
        try await getChatDocument(for: id).updateData(dict)
    }
    
    func viewLastChatMessage(for id: String)  async throws{
        let dict: [String: Any] = [
           "lastMessage.viewed" : true
        ]
        try await getChatDocument(for: id).updateData(dict)
    }
    
    func deleteChat(for id: String) async throws{
        try await getChatDocument(for: id).delete()
    }
    
    func chatQuery(userId: String, limit: Int? = nil) -> Query{
        chatsCollections
            .limitOptionally(to: limit)
            .whereField(Chat.CodingKeys.participantsIds.rawValue, arrayContains: userId)
            .order(by: Chat.CodingKeys.createdAt.rawValue)
    }
    
    func getUserChats(userId: String) async throws -> [Chat]{
        try await chatQuery(userId: userId)
            .getDocuments(as: Chat.self)
    }
    
    func getChat(participantId: String, currentUserId: String) async throws -> Chat?{
        return try await chatsCollections
            .whereField(Chat.CodingKeys.participantsIds.rawValue, arrayContains: participantId)
            .getDocuments(as: Chat.self)
            .first(where: {$0.participantsIds.contains(currentUserId)})
    }
    
    func addChatListener(userId: String) ->(AnyPublisher<([Chat: DocumentChangeType]), Error>, ListenerRegistration){
        chatQuery(userId: userId, limit: nil)
            .addSnapshotListenerWithChangeType(as: Chat.self)
    }
}

