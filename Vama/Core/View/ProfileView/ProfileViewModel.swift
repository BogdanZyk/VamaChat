//
//  ProfileViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    @Published var userInfo = User.UserInfo.empty()
    @Published var isChange: Bool = false
    @Published var showLoader: Bool = false
    @Published var error: Error?
    
    @Published var selectedImage: NSImage?
    private let userService = UserService.share
    private var cancelBad = CancelBag()

 
    func setInfo(_ user: User?) {
        guard let user else { return }
        userInfo = user.getInfo()
        startOnChangeSubs()
    }
    
    var isDisabled: Bool {
        !isChange || userInfo.firstName.isEmpty || userInfo.username.isEmpty || showLoader
    }
    
    func updateUserInfo(completion: (() -> Void)? = nil) {
        showLoader = true
        Task {
            do {
                try await userService.updateUserInfo(userInfo)
                
                if let selectedImage{
                    try await userService.updateUserPhoto(image: selectedImage, lastImagePath: userInfo.imagePath)
                }

                Task.main{
                    showLoader = false
                    isChange = false
                    completion?()
                }
            } catch {
                Task.main {
                    showLoader = false
                    self.error = error
                }
            }
        }
    }
    
    func selectImageFromImporter(_ res: Result<URL, Error>) {
        switch res {
        case .success(let url):
            if let image = NSImage(contentsOf: url){
                DispatchQueue.main.async {
                    self.selectedImage = image
                }
            }
        case .failure(let failure):
            print(failure.localizedDescription)
        }
    }
    
    private func startOnChangeSubs() {
        $userInfo
            .combineLatest($selectedImage)
            .dropFirst()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { _ in
                print("isChange")
                self.isChange = true
            }
            .store(in: cancelBad)
    }

    
}
