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
    
    func sendMessage(for id: String, message: Message) async throws{
        try getMessageCollectionRef(chatId: id).document(message.id)
            .setData(from: message)
        try await chatService.updateLastChatMessage(for: id, message: message)
    }
    
    func updateMessage(for id: String, message: Message, isUpdateLastMessage: Bool) async throws{
        try await getMessageCollectionRef(chatId: id).document(message.id)
            .updateData([Message.CodingKeys.message.rawValue: message.message ?? ""])
        if isUpdateLastMessage{
            try await chatService.updateLastChatMessage(for: id, message: message)
        }
        if message.pinned{
            try await updatePinMessage(for: id, message: message)
        }
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
    
    func addListenerForMessages(chatId: String) -> (AnyPublisher<([(item: Message, type: DocumentChangeType)], DocumentSnapshot?), Error>, ListenerRegistration){
        messageQuery(chatId: chatId, limit: 30)
            .addSnapshotListenerWithChangeType(as: Message.self)
    }
    
    func viewMessage(for chatId: String, messageId: String, uid: String) async throws{
       
        let dict: [String: Any] = [
            Message.CodingKeys.viewedIds.rawValue: FieldValue.arrayUnion([uid])
        ]
        
        try await getMessageCollectionRef(chatId: chatId).document(messageId).updateData(dict)
        try await chatService.viewLastChatMessage(for: chatId, uid: uid)
    }
    
    func removeMessage(for chatId: String, message: Message, lastMessage: Message? = nil) async throws{
        try await getMessageCollectionRef(chatId: chatId).document(message.id).delete()
        
        if let lastMessage{
            try await chatService.updateLastChatMessage(for: chatId, message: lastMessage)
        }
        
        if message.pinned{
            try await unpinMessage(for: chatId, messageId: message.id, withUpdate: false)
        }
        
        if let paths = message.media?.compactMap({$0.item?.path}){
            for try await item in SomeAsyncSequence(elements: paths){
                try? await StorageManager.shared.deleteAsset(path: item)
            }
        }
    }
}


//MARK: - Pinned messages
extension MessageService{
    
    private func getPinnedMessageCollectionRef(chatId: String) -> CollectionReference{
        chatService.getChatDocument(for: chatId).collection("pinned_messages")
    }
    
    func addListenerForPinMessages(chatId: String) -> FBListenerResult<Message>{
        getPinnedMessageCollectionRef(chatId: chatId)
            .addSnapshotListener(as: Message.self)
    }
    
    func pinMessage(for id: String, message: Message) async throws{
        try getPinnedMessageCollectionRef(chatId: id).document(message.id)
            .setData(from: message, merge: false)
        try await updatePinMessageFlag(for: id, messageId: message.id, pinned: true)
    }
    
    func unpinMessage(for id: String, messageId: String, withUpdate: Bool = true) async throws{
        try await getPinnedMessageCollectionRef(chatId: id).document(messageId).delete()
        if withUpdate{
            try await updatePinMessageFlag(for: id, messageId: messageId, pinned: false)
        }
    }

    func updatePinMessage(for id: String, message: Message) async throws{
        try await getPinnedMessageCollectionRef(chatId: id).document(message.id)
            .updateData([Message.CodingKeys.message.rawValue: message.message ?? ""])
    }
    
    func updatePinMessageFlag(for id: String, messageId: String, pinned: Bool) async throws{
        try await getMessageCollectionRef(chatId: id).document(messageId)
            .updateData([Message.CodingKeys.pinned.rawValue: pinned])
    }
}
