//
//  Query.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FBListenerResult<T: Decodable>{
    
    let publisher: AnyPublisher<[T], Error>
    let listener: ListenerRegistration
    
}

struct FBLastDoc{
    var lastDocument: DocumentSnapshot?
}

extension Query{
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable {
        let snapshot = try await getDocuments()
        return try snapshot.documents.map({try $0.data(as: T.self)})
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> ([T], DocumentSnapshot?) where T: Decodable {
        let snapshot = try await getDocuments()
        let items = try snapshot.documents.map({try $0.data(as: T.self)})
        return (items, snapshot.documents.last)
    }
        
    func addSnapshotListener<T>(as type: T.Type) -> FBListenerResult<T> where T: Decodable{
        let publisher = PassthroughSubject<[T], Error>()
        let listener = addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                return
            }
            let items: [T] = documents.compactMap({ try? $0.data(as: T.self)})
            publisher.send(items)
        }
        return .init(publisher: publisher.eraseToAnyPublisher(), listener: listener)
    }
    
    func addSnapshotListenerWithChangeType<T>(as type: T.Type) -> (AnyPublisher<([T], [DocumentChangeType]), Error>, ListenerRegistration) where T: Decodable{
        let publisher = PassthroughSubject<([T], [DocumentChangeType]), Error>()
        let listener = addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents, let changest = querySnapshot?.documentChanges else{
                return
            }
            let items: [T] = documents.compactMap({ try? $0.data(as: T.self)})
            let changeTypes = changest.compactMap({ $0.type })
            publisher.send((items, changeTypes))
        
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
    func startOptionally(afterDocument lastDoc: DocumentSnapshot?) -> Query{
        guard let lastDoc else { return self }
        return self.start(afterDocument: lastDoc)
    }
    
    func limitOptionally(to limit: Int?) -> Query{
        guard let limit else { return self }
        return self.limit(to: limit)
    }
    
    func whereFieldOptionally(_ key: String, isEqualTo: String?) -> Query{
        guard let isEqualTo else { return self }
        return self.whereField(key, isEqualTo: isEqualTo)
    }
}


extension DocumentReference{
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<T?, Error>, ListenerRegistration) where T: Decodable{
        let publisher = PassthroughSubject<T?, Error>()
        let listener = addSnapshotListener { querySnapshot, error in
            let item = try? querySnapshot?.data(as: T.self)
            publisher.send(item)
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
}
