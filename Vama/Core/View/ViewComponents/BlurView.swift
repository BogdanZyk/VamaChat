//
//  BlurView.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

struct BlurView: NSViewRepresentable {
   
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
}

