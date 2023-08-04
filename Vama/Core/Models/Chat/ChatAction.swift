//
//  ChatAction.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation

enum ChatContextAction: Int, CaseIterable{
    case pin, archive, clear, remove
    
    var image: String{
        switch self {
        case .pin: return "pin"
        case .archive: return "archivebox"
        case .clear: return "trash"
        case .remove: return "trash"
        }
    }
    
    var title: String{
        switch self {
        case .pin: return "Pin"
        case .archive: return "Archive"
        case .clear: return "Clear history"
        case .remove: return "Remove"
        }
    }
}
