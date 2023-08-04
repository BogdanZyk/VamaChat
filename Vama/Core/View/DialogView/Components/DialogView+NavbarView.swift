//
//  DialogView+NavbarView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

extension DialogView{
    struct NavBarView: View {
        @EnvironmentObject var viewModel: DialogViewModel
        private var isPrivateChat: Bool{
            viewModel.chatData.chat.chatType == .chatPrivate
        }
        var body: some View {
            VStack(alignment: .leading) {
                HStack{
                   chatInfoView
                }
                .padding(.horizontal)
                .padding(.top, 10)
                Divider()
            }
        }
    }
}


struct NavbarView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView.NavBarView()
    }
}

extension DialogView.NavBarView{
    
    private var chatInfoView: some View{
        Group{
            AvatarView(image: isPrivateChat ? viewModel.chatData.target?.image : viewModel.chatData.chat.photo, size: .init(width: 30, height: 30))
            
            VStack(alignment: .leading) {
                Text(isPrivateChat ? (viewModel.chatData.target?.fullName ?? "") : viewModel.chatData.chat.title ?? "")
                    .font(.body.bold())
                Text("status")
            }
        }
    }
    
}
