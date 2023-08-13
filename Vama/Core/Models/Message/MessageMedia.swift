//
//  MessageMedia.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI

struct MessageMedia: Identifiable, Codable, Hashable{
    var id: String = UUID().uuidString
    let type: MediaType
    var path: String
    var thumbnail: NSImage?
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case path
    }
    
    mutating func setPath(_ path: String){
        self.path = path
    }
}


extension MessageMedia{
    enum MediaType: String, Codable{
        case image, video
    }
}

