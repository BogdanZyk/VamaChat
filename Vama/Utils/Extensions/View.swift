//
//  View.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

extension View{
    
    
    /// Get bounds screen
    func getRect() -> CGRect{
        return NSScreen.main!.frame
    }
    
    /// Vertical Center
    func vCenter() -> some View{
        self
            .frame(maxHeight: .infinity, alignment: .center)
    }
    /// Vertical Top
    func vTop() -> some View{
        self
            .frame(maxHeight: .infinity, alignment: .top)
    }
    
    /// Vertical Bottom
    func vBottom() -> some View{
        self
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
    /// Horizontal Center
    func hCenter() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    /// Horizontal Leading
    func hLeading() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    /// Horizontal Trailing
    func hTrailing() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    /// All frame
    func allFrame() -> some View{
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Off animation for view
    func withoutAnimation() -> some View {
        self.animation(nil, value: UUID())
    }
    
}
