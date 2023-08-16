//
//  AppCommands.swift
//  Vama
//
//  Created by Bogdan Zykov on 16.08.2023.
//

import SwiftUI

struct AppCommands: Commands {
    var router: MainRouter
    var body: some Commands {
        CommandMenu("Vama") {
            Button("About Vama", action: {})
            Divider()
            Button("Settings"){
                router.setTab(.settings)
            }
            Divider()
            Button("Profile"){
                router.setTab(.profile)
            }
            Button("Chats"){
                router.setTab(.chats)
            }
            Divider()
            Button("Quit Vama"){
                NSApp.terminate(nil)
            }
        }
    }
}
