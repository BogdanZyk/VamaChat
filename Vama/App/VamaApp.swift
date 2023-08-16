//
//  VamaApp.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI
import Firebase

@main
struct VamaApp: App {
    @StateObject var router = MainRouter()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
        }
        .commands {
            AppCommands(router: router)
        }
    }
}


