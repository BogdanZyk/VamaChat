//
//  DialogView+ScrollToBottomButton.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension DialogView {
    
    @ViewBuilder
    func scrollToBottomButton(_ proxy: ScrollViewProxy) -> some View{
        if let id = viewModel.messages.first?.id, !hiddenDownButton{
            Image(systemName: "chevron.down")
                .padding(10)
                .background(Color(nsColor: .windowBackgroundColor), in: Circle())
                .overlay {
                    Circle()
                        .stroke(lineWidth: 1)
                }
                .foregroundColor(.white)
                .padding(.bottom, 10)
                .padding(.trailing, 5)
                .transition(.move(edge: .bottom).combined(with: .scale).combined(with: .opacity))
                .onTapGesture {
                    scrollTo(proxy, id: id)
                }
        }
    }
    
    func scrollTo(_ proxy: ScrollViewProxy, id: String?){
        withAnimation {
            proxy.scrollTo(id, anchor: .bottom)
        }
    }
    
}
