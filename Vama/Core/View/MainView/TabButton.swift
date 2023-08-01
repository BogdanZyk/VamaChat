//
//  TabButton.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

struct TabButton: View {
    var tab: MainTab
    @Binding var currentTab: MainTab
    @State var onHover: Bool = false
    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: tab.image)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(currentTab == tab ? .white : .gray)
            
            Text(tab.rawValue)
                .fontWeight(.semibold)
                .font(.system(size: 10))
                .foregroundColor(currentTab == tab ? .white : .gray)
        }
        .padding(.vertical, 8)
        .frame(width: 60)
        .background(.primary.opacity((currentTab == tab || onHover) ? 0.15 : 0))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            currentTab = tab
        }
        .onHover { isHover in
            withAnimation {
                onHover = isHover
            }
        }
    }
}

struct TabButton_Previews: PreviewProvider {
    static var previews: some View {
        TabButton(tab: .chats, currentTab: .constant(.chats))
            .padding()
    }
}

