//
//  ChatsView.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

struct ChatsView: View {
    @EnvironmentObject var router: MainRouter
    @StateObject var chatVM = ChatViewModel()
    @State var query: String = ""
    @State var showSearchList: Bool = false
    var body: some View {
        VStack(spacing: 10) {
            SearchTextField(query: $query){ isFocused in
                showSearchList = isFocused
            }
            if showSearchList{
                SearchListView()
            }else{
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: 0){
                        ForEach(chatVM.chats) { chatData in
                            ChatRowView(
                                chatData: chatData,
                                isSelected: chatData == chatVM.selectedChat,
                                onTap: chatVM.selectChat,
                                onContextAction: chatVM.setChatAction)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: showSearchList)
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
            .environmentObject(MainRouter())
    }
}


