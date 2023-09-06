//
//  Router.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import Foundation

final class MainRouter: ObservableObject {
    
    @Published var currentTab: MainTab = .chats
    @Published var imageViewer = ImageViewer()
    @Published var sheetDestination: SheetDestination?
    
    func setTab(_ tab: MainTab) {
        currentTab = tab
    }
    
    
}





enum SheetDestination: Identifiable{
    
    case chatListModal(ChatModalSetter)
    
    var id: Int{
        switch self {
        case .chatListModal: return 0
        }
    }
}
