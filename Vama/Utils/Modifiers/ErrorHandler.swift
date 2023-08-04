//
//  ErrorHandler.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

public struct ErrorHandleModifier: ViewModifier {
    @Binding var error: Error?

    public func body(content: Content) -> some View {
        content
            .alert(Text("Error"),
                   isPresented: .init(get: {error != nil}, set: {state in
                if !state{
                    error = nil
                }
            }),
                   actions: {Button("OK", role: .cancel, action: {})},
                   message: {Text(error?.localizedDescription.prefix(100) ?? "")}
            )
    }
}

extension View {
    public func handle(error: Binding<Error?>) -> some View {
        modifier(ErrorHandleModifier(error: error))
    }
}
