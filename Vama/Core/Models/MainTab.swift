//
//  MainTab.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

enum MainTab: String, CaseIterable{
    case chats = "Chats"
    case profile = "Profile"
//    case settings = "Settings"
    
    var image: String{
        switch self {
        case .chats: return "message"
        case .profile: return "person"
//        case .settings: return "gear"
        }
    }
}
