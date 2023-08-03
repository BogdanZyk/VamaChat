//
//  MessageAction.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation

enum MessageContextAction: Int, CaseIterable{
    
    case answer, copy, edit, pin, forward, select, remove
    
    var image: String{
        switch self {
        case .answer: return "arrowshape.turn.up.backward"
        case .copy: return "doc.on.doc"
        case .pin: return "pin"
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
        case .edit: return "Edit"
        case .forward: return "Forward"
        case .remove: return "Remove"
        case .select: return "Select"
        }
    }
}
