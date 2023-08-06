//
//  MessageService.swift
//  Vama
//
//  Created by Bogdan Zykov on 06.08.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine


final class MessageService{
    
    private init() {}
    
    static let shared = MessageService()
    
    private let chatService = ChatServices.shared
    
    
    private func getMessageCollectionRef(chatId: String) -> CollectionReference{
        chatService.getChatDocument(for: chatId).collection("messages")
    }
    
    func sendMessage(for id: String, _ message: Message) async throws{
        try getMessageCollectionRef(chatId: id).document(message.id)
            .setData(from: message, merge: false)
        try await chatService.updateLastChatMessage(for: id, message: message)
    }
    
    func messageQuery(chatId: String, limit: Int? = 20) -> Query{
        getMessageCollectionRef(chatId: chatId)
            .limitOptionally(to: limit)
            .order(by: Message.CodingKeys.createdAt.rawValue, descending: true)
    }
    
    func fetchPaginatedMessage(for chatId: String, lastDocument: DocumentSnapshot?) async throws -> ([Message], lastDoc: DocumentSnapshot?){
        try await messageQuery(chatId: chatId)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Message.self)
    }
    
    func getCountAllMessages(chatId: String) async throws -> Int{
        let snapshot = try await messageQuery(chatId: chatId, limit: nil)
            .count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addListenerForMessages(chatId: String) -> (AnyPublisher<([Message : DocumentChangeType]), Error>, ListenerRegistration){
        messageQuery(chatId: chatId, limit: 1)
            .addSnapshotListenerWithChangeType(as: Message.self)
    }
    
    func viewMessage(for chatId: String, message: Message, uid: String) async throws{
       
        let dict: [String: Any] = [
            Message.CodingKeys.viewedIds.rawValue: FieldValue.arrayUnion([uid])
        ]
        
        try await getMessageCollectionRef(chatId: chatId).document(message.id).updateData(dict)
        try await chatService.updateLastChatMessage(for: chatId, message: message)
    }
}
