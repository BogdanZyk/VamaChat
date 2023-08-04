//
//  AuthenticationManager.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation
import FirebaseAuth
import Combine

final class AuthenticationManager{
   
    static let share = AuthenticationManager()
    
    func getAuthUser() -> AuthResult?{
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return AuthResult(user: user)
    }
    
    func signOut() throws{
        try Auth.auth().signOut()
    }
    
    private func createUser(_ user: User) async throws{
        try await UserService.share.createUserIfNeeded(user: user)
    }
}


//MARK: - Sign in with email
extension AuthenticationManager{
    
    @discardableResult
    func createUser(email: String, pass: String, nickname: String) async throws -> AuthResult{
        let result = try await Auth.auth().createUser(withEmail: email, password: pass)
        let authDataResult = AuthResult(user: result.user)
        try await createUser(authDataResult.getUser(username: nickname))
        return authDataResult
    }
    
    @discardableResult
    func signInWithEmail(email: String, pass: String) async throws -> AuthResult{
        let result = try await Auth.auth().signIn(withEmail: email, password: pass)
        return .init(user: result.user)
    }
}




struct AuthResult{
    let uid: String
    let email: String?
    let photoUrl: String?
    
    
    init(user: FirebaseAuth.User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
    
    func getUser(username: String) -> User{
        .init(id: uid, username: username, email: email)
    }
}


