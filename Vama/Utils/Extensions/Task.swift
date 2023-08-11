//
//  Task.swift
//  Vama
//
//  Created by Bogdan Zykov on 11.08.2023.
//

import Foundation

extension Task where Failure == Error {
    static func main(
        priority: TaskPriority? = nil,
        @_implicitSelfCapture _ operation: @escaping @MainActor @Sendable () -> Success
    ) {
        Task { @MainActor in
            operation()
        }
    }
}
