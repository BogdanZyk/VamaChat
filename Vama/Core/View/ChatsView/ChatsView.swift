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
    @StateObject var searchVM = SearchViewModel()
    var body: some View {
        VStack(spacing: 10) {
            searchField
            if searchVM.showSearchList{
                SearchListView(users: searchVM.results, onTap: searchVM.selectedUser)
            }else{
                chatsListSection
            }
        }
        .animation(.easeInOut, value: searchVM.showSearchList)
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
            .environmentObject(MainRouter())
    }
}


extension ChatsView{
    
    private var searchField: some View{
        SearchTextField(query: $searchVM.query){ isFocused in
            searchVM.showSearchList = isFocused
        }
    }
    
}

extension ChatsView{
    
    private var chatsListSection: some View{
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
