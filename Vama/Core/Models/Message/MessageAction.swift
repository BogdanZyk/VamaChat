//
//  MessageAction.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation

enum MessageContextAction: Int{
    
    case answer, copy, edit, pin, unpin, forward, select, remove
    
    var image: String{
        switch self {
        case .answer: return "arrowshape.turn.up.backward"
        case .copy: return "doc.on.doc"
        case .pin: return "pin"
        case .unpin: return "pin.slash"
        case .edit: return "square.and.pencil"
        case .forward: return "arrowshape.turn.up.right"
        case .remove: return "trash"
        case .select: return "checkmark.circle"
        }
    }
    
    var title: String{
        switch self {
        case .answer: return "Answer"
        case .copy: return "Copy"
        case .pin: return "Pin"
        case .unpin: return "Unpin"
        case .edit: return "Edit"
        case .forward: return "Forward"
        case .remove: return "Remove"
        case .select: return "Select"
        }
    }
    
   static func getAllCases(isPin: Bool, isCurrentUser: Bool) -> [MessageContextAction]{
        var actions: [MessageContextAction] = [.answer, .copy, (isPin ? .unpin : .pin), .forward, .select]
        
        if isCurrentUser{
            actions.append(contentsOf: [.edit, .remove])
        }
        
        return actions
    }
}
