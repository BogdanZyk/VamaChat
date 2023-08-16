//
//  NavigationHeaderView.swift
//  Vama
//
//  Created by Bogdan Zykov on 16.08.2023.
//

import SwiftUI

struct NavigationHeaderView <RightItem: View>: View {
    
    let title: String
    var rightItem: (() -> RightItem)?
    var backAction: (() -> Void)?
    
    init(title: String, backAction: (() -> Void)? = nil) {
        self.title = title
        self.backAction = backAction
    }
    
    init(title: String,
         backAction: (() -> Void)? = nil,
         @ViewBuilder rightItem: @escaping () -> RightItem) {
        
        self.title = title
        self.backAction = backAction
        self.rightItem = rightItem
    }
    
    var body: some View {
        HStack{
            if let backAction {
                Button {
                    backAction()
                } label: {
                    Label {
                        Text("Back")
                    } icon: {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            rightItem?()
        }
        .padding(.horizontal)
        .frame(height: 50)
        .hCenter()
        .background(Color(nsColor: .darkGray))
        .overlay(alignment: .center) {
            Text(title)
                .font(.body.weight(.medium))
        }
    }
}

struct NavigationHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationHeaderView<EmptyView>(title: "Title")
    }
}
