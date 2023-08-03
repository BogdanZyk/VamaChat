//
//  MessageMedia.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation

struct MessageMedia: Identifiable, Codable, Hashable{
    var id: String = UUID().uuidString
    let type: MediaType
    let path: String
}


extension MessageMedia{
    enum MediaType: Codable{
        case image, video
    }
}
