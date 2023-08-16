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
    
    private let usersCollection = FbFirestoreService.shared.db.collection("users")
    
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
    
    func updateUserPhoto(image: NSImage, lastImagePath: String?) async throws {
        
        guard let id = getFBUserId() else {
            throw AppError.custom(errorDescription: "No init firebase user")
        }
        
        let manager = StorageManager.shared
        let newImage = try await manager.uploadImage(image: image, type: .avatar, id: id)
        let dict = [User.CodingKeys.profileImage.rawValue: try newImage.getData()]
        try await userDocument(for: id).updateData(dict)
        
        if let lastImagePath {
            try await manager.deleteAsset(path: lastImagePath)
        }
    }
    
    func updateUserStatus(_ status: OnlineStatus.UserStatus) async throws{
        guard let id = getFBUserId() else {
            throw AppError.custom(errorDescription: "No init firebase user")
        }
        let onlineStatus = OnlineStatus(status: status)
        let data = try Firestore.Encoder().encode(onlineStatus)
        let dict: [String: Any] = [
            User.CodingKeys.status.rawValue: data
        ]
        
        try await userDocument(for: id).updateData(dict)
    }
    
    func addUserListener(for id: String) -> (AnyPublisher<User?, Error>, ListenerRegistration){
        userDocument(for: id).addSnapshotListener(as: User.self)
    }
    
    func removeUser(for id: String) async throws{
        try await userDocument(for: id).delete()
    }
    
    
    func findUsers(query: String) -> FBListenerResult<User>{
        
        let field = User.CodingKeys.username.rawValue
        
        return usersCollection
            .order(by: field)
            .whereField(field, isGreaterThanOrEqualTo: query)
            .whereField(field, isLessThanOrEqualTo: query+"\u{F7FF}")
            .addSnapshotListener(as: User.self)
    }
    
    func getUsers(ids: [String]) async throws -> [User]{
        return try await withThrowingTaskGroup(of: User.self, returning: [User].self) { taskGroup in
            for id in ids{
                taskGroup.addTask { [weak self] in
                    guard let self = self else {
                        throw AppError.custom(errorDescription: "Error in get users")
                    }
                    return try await self.getUser(for: id)
                }
            }
            return try await taskGroup.reduce(into: [User]()) { partialResult, name in
                partialResult.append(name)
            }
        }
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


//func userStatus(_ status: UserStatus) {
//    switch status {
//        case .userStatusEmpty:
//            onlineStatus = "empty"
//        case .userStatusOnline: // (let userStatusOnline)
//            onlineStatus = "online"
//        case .userStatusOffline(let userStatusOffline):
//            onlineStatus = "last seen \(getLastSeenTime(from: userStatusOffline.wasOnline))"
//        case .userStatusRecently:
//            onlineStatus = "last seen recently"
//        case .userStatusLastWeek:
//            onlineStatus = "last seen last week"
//        case .userStatusLastMonth:
//            onlineStatus = "last seen last month"
//    }
//}
