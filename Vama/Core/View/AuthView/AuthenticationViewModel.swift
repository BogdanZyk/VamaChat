//
//  AuthenticationViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation


@MainActor
final class AuthenticationViewModel: ObservableObject{
 
    private let manager = AuthenticationManager.share
    
    @Published private(set) var isSingIn: Bool = false
    @Published private(set) var showLoader: Bool = false
    @Published var error: Error?
    
    init(){
        checkAuthUser()
    }
    
    func checkAuthUser(){
        isSingIn = manager.getAuthUser() != nil
    }
    
    func singOut(){
        try? manager.signOut()
        isSingIn = false
        //UserPreferences.shared.clearAll()
    }
    
    private func handleError(_ error: Error){
        isSingIn = false
        showLoader = false
        self.error = error
    }
    
    private func handleResult(){
        isSingIn = true
        showLoader = false
    }
}

extension AuthenticationViewModel{
    
    func singUpWithEmail(email: String, pass: String, nickname: String) async{
        showLoader = true
        do{
            try await manager.createUser(email: email, pass: pass, nickname: "@\(nickname)")
            handleResult()
        }catch{
            print("ERROR", error)
            handleError(error)
        }
    }
    
    func singInWithEmail(email: String, pass: String) async{
        showLoader = true
        do{
            try await manager.signInWithEmail(email: email, pass: pass)
            handleResult()
        }catch{
            handleError(error)
        }
    }
}
