//
//  FbFirestore.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FbFirestoreService {
    static let shared = FbFirestoreService()
    
    let db = Firestore.firestore()
    
    private init() {}
    
    func configure() {
        let settings = FirestoreSettings()
        // Use persistent disk cache, with 100 MB cache size
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        db.settings = settings
    }
}
