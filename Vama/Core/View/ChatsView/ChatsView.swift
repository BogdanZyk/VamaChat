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
                searchList
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
        SearchTextField(query: $searchVM.query, onChangeFocus: searchVM.activateOrDeactivateSearch)
    }
    
}

extension ChatsView{
    
    @ViewBuilder
    private var chatsListSection: some View{
        if chatVM.chats.isEmpty{
            Text("Use the search to create a chat room")
                .multilineTextAlignment(.center)
                .padding()
                Spacer()
        }else{
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading, spacing: 0){
                    ForEach(chatVM.chats) { chatData in
                        ChatRowView(
                            chatData: chatData,
                            isSelected: chatData == chatVM.selectedChat,
                            onTap: {chatVM.selectChatConversation($0)},
                            onContextAction: {chatVM.setChatAction($0, $1)})
                    }
                }
            }
        }
    }
    
    private var searchList: some View{
        SearchListView(users: searchVM.results, state: searchVM.viewState){ user in
            searchVM.resetSearch()
            chatVM.createChatConversation(for: user)
        }
    }
}
