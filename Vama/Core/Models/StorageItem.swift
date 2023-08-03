//
//  StorageItem.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation

struct StorageItem: Identifiable, Codable, Hashable{
    
    let path: String
    let fullPath: String
    var id: String { path }
    
    var url: URL?{
        URL(string: fullPath)
    }
    
    func getData() throws -> [String : Any]{
        [:]
      //  try Firestore.Encoder().encode(self)
    }
    
}
