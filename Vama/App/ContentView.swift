//
//  ContentView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

struct ContentView: View {
    @State var isLogged: Bool = false
    var body: some View {
        Group{
            //if isLogged{
                MainView()
//            }else{
//                AuthView(isLoggin: $isLogged)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
