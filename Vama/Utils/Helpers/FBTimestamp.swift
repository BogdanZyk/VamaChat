//
//  FBTimestamp.swift
//  Vama
//
//  Created by Bogdan Zykov on 06.08.2023.
//

import Foundation
import FirebaseFirestore


struct FBTimestamp: Codable, Hashable{
    
    let timestamp: Timestamp

    init(date: Date = .now){
        self.timestamp = Timestamp(date: date)
    }
    
    var date: Date{
        timestamp.dateValue()
    }
}
