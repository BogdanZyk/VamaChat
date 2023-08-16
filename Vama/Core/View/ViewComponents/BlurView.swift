//
//  BlurView.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

struct BlurView: NSViewRepresentable {
   
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = blendingMode
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
}

