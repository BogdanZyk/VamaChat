//
//  DialogViewModel+BottomActionType.swift
//  Vama
//
//  Created by Bogdan Zykov on 06.08.2023.
//

import Foundation

extension DialogViewModel{
    
    enum BottomBarActionType{
        case edit(Message), answer(Message), empty
        
        var id: Int{
            switch self{
            case .edit: return 0
            case .answer: return 1
            case .empty: return 2
            }
        }
        
        var message: Message?{
            switch self{
            case .edit(let message): return message
            case .answer(let message): return message
            case .empty: return nil
            }
        }
    }
    
    func setBottomBarAction(_ bottomBarActionType: BottomBarActionType){
        self.bottomBarActionType = bottomBarActionType
    }
    
    func resetBottomBarAction(){
        bottomBarActionType = .empty
    }
    
}
