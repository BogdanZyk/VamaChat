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
    @State var searchText: String = ""
    var body: some View {
        VStack(spacing: 10) {
            searchView
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
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
            .environmentObject(MainRouter())
    }
}


extension ChatsView{
    private var searchView: some View{
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.primary.opacity(0.15))
        .cornerRadius(10)
        .padding(10)
    }
}
