//
//  Combine.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation
import Combine

final class CancelBag {
    fileprivate(set) var subscriptions = Set<AnyCancellable>()
    
    func cancel() {
        subscriptions.removeAll()
    }
}

extension AnyCancellable {
    
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
