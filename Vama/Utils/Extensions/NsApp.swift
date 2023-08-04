//
//  NsApp.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

extension NSApplication{
    
    func endEditing(){
        NSApplication.shared.mainWindow?.perform(
             #selector(NSApplication.shared.mainWindow?.makeFirstResponder(_:)),
             with: nil,
             afterDelay: 0.0
         )
    }
}


