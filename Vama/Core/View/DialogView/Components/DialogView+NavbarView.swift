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
                
                pinMessageSection
            }
        }
    }
}


struct NavbarView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView.NavBarView()
            .environmentObject(DialogViewModel(chatData: .mocks.first!, currentUser: .mock))
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
    
    
    @ViewBuilder
    private var pinMessageSection: some View{
        if !viewModel.pinnedMessages.isEmpty, let last = viewModel.pinnedMessages.last{
            VStack{
                HStack{
                    VStack(spacing: 2){
                        ForEach(viewModel.pinnedMessages.indices, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.cyan)
                                .frame(width: 2)
                            
                        }
                    }
                    .frame(height: 32)
                    
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pin message")
                                .font(.system(size: 12, weight: .medium))
                            Text(last.message ?? "")
                                .font(.system(size: 12, weight: .light))
                                .lineLimit(1)
                        }
                        Spacer()
                        Button {
                            viewModel.pinOrUnpinMessage(message: last, onPinned: false)
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.title3)
                                .foregroundColor(Color.cyan)
                        }
                        .buttonStyle(.plain)
                    
                }
                .padding(.horizontal)
                Divider()
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: viewModel.onTapPinMessage)
        }
    }
}
