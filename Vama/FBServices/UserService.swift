//
//  UserService.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Combine

final class UserService{
 
    
    static let share = UserService()
    
    private init() {}
    
    private let usersCollection = Firestore.firestore().collection("users")
    
    private func userDocument(for id: String) -> DocumentReference{
        usersCollection.document(id)
    }
    
    func getAuthData() -> AuthResult?{
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return AuthResult(user: user)
    }
    
    func getFBUserId() -> String?{
        Auth.auth().currentUser?.uid
    }
    
    func createUserIfNeeded(user: User) async throws{
        let doc = try await userDocument(for: user.id).getDocument()
        if !doc.exists{
            try userDocument(for: user.id).setData(from: user, merge: false)
        }
    }
    
    func getCurrentUser() async throws -> User{
        
        guard let id = getFBUserId() else {
            throw AppError.custom(errorDescription: "No init firebase user")
        }
        
        return try await getUser(for: id)
    }
    
    func getUser(for id: String) async throws -> User{
        try await userDocument(for: id).getDocument(as: User.self)
    }
    
    func updateUserInfo(_ info: User.UserInfo) async throws{
        try await userDocument(for: info.id).updateData(info.getDict())
    }
    
    func addUserListener(for id: String) -> (AnyPublisher<User?, Error>, ListenerRegistration){
        userDocument(for: id).addSnapshotListener(as: User.self)
    }
    
    func removeUser(for id: String) async throws{
        try await userDocument(for: id).delete()
    }
}






extension UserService{
    
    
//    func setImageUrl(for type: ProfileImageType, userId: String, image: StoreImage) async throws{
//        try await userDocument(for: userId).updateData(type.getDict(image))
//    }

}


struct FBListener{
    
    var listener: ListenerRegistration?
    
    func cancel(){
        listener?.remove()
    }
    
}
