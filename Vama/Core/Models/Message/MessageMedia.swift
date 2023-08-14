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
    var item: StorageItem?
    var thumbnail: NSImage?
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case item
    }
}


extension MessageMedia{
    enum MediaType: String, Codable{
        case image, video
    }
}

