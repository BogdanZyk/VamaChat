//
//  Router.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import Foundation

final class MainRouter: ObservableObject {
    
    @Published var currentTab: MainTab = .chats
    
    func setTab(_ tab: MainTab) {
        currentTab = tab
    }
    
}



