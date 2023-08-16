//
//  AppDelegate.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// Don't work in applicationDidFinishLaunching
    override init() {
        FirebaseApp.configure()
        FbFirestoreService.shared.configure()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
       
        // Remove unused Multiple Menus
        ["Edit", "View", "Help", "Window", "File", "Vama"].forEach { name in
            NSApp.mainMenu?.item(withTitle: name).map { NSApp.mainMenu?.removeItem($0) }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Task{
           try? await UserService.share.updateUserStatus(.offline)
        }
    }
    
}

