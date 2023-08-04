//
//  ContentView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authManager = AuthenticationViewModel()
    var body: some View {
        Group{
            if authManager.isSingIn{
                MainView()
                    .environmentObject(authManager)
            }else{
                AuthView(authVM: authManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
