//
//  AuthView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

struct AuthView: View {
    @Binding var isLoggin: Bool
    var body: some View {
        VStack{
            Button("Log in"){
                isLoggin.toggle()
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(isLoggin: .constant(false))
    }
}
