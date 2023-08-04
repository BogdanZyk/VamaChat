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
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
       
    }
    
    
}

