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
    
    func addSnapshotListenerWithChangeType<T>(as type: T.Type) -> (AnyPublisher<([(item: T, type: DocumentChangeType)], DocumentSnapshot?), Error>, ListenerRegistration) where T: Decodable, T: Hashable{
        
        let publisher = PassthroughSubject<([(item: T, type: DocumentChangeType)], DocumentSnapshot?), Error>()

        let listener = addSnapshotListener { querySnapshot, error in
            guard let changest = querySnapshot?.documentChanges else{
                return
            }
            
            var changeData = [(item: T, type: DocumentChangeType)]()

            changest.forEach{
                guard let item: T = try? $0.document.data(as: T.self) else {return}
                let type = $0.type
                changeData.append((item: item, type: type))
            }
            publisher.send((changeData, changest.last?.document))
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
