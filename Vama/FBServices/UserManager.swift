//
//  UserManager.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation

@MainActor
class UserManager: ObservableObject{
    
    let userService = UserService.share
    @Published var user: User?
    @Published var error: Error?
    private var userListener = FBListener()
    private let cancelBag = CancelBag()
    
    init(){
        startUserListener()
    }
    
    deinit{
        userListener.cancel()
    }
    
    var userId: String?{
        userService.getFBUserId()
    }
    
    func refetchUser(){
        Task{
            do{
                let user = try await userService.getCurrentUser()
                self.user = user
            }catch{
                self.error = error
            }
        }
    }
    
    private func startUserListener(){
        guard let id = userId else {return}
        
        let (pub, listener) = userService.addUserListener(for: id)
        
        self.userListener.listener = listener
        
        pub
            .sink { [weak self] completion in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
            } receiveValue: { [weak self] user in
                guard let self = self else {return}
                self.user = user
            }
            .store(in: cancelBag)
    }
}
