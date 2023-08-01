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
    var body: some View {
        Button {
            withAnimation {
                currentTab = tab
            }
        } label: {
            VStack(spacing: 7) {
                Image(systemName: tab.image)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(currentTab == tab ? .white : .gray)
                
                Text(tab.rawValue)
                    .fontWeight(.semibold)
                    .font(.system(size: 11))
                    .foregroundColor(currentTab == tab ? .white : .gray)
            }
            .padding(.vertical, 8)
            .frame(width: 60)
            .background(.primary.opacity(currentTab == tab ? 0.15 : 0))
        }
        .buttonStyle(.plain)
    }
}

struct TapButton_Previews: PreviewProvider {
    static var previews: some View {
        TabButton(tab: .home, currentTab: .constant(.home))
    }
}

