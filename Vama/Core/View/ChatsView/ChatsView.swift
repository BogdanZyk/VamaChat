//
//  ChatsView.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

struct ChatsView: View {
    @EnvironmentObject var router: MainRouter
    @State var searchText: String = ""
    var body: some View {
        VStack(spacing: 10) {
            searchView
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading, spacing: 0){
                    ForEach(1...50, id: \.self) { index in
                        HStack(alignment: .top, spacing: 10){
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 45, height: 45)
                            VStack(alignment: .leading, spacing: 3){
                                Text("User Name")
                                    .font(.body.bold())
                                Text("Message \(index)")
                                    .font(.caption.weight(.light))
                            }
                        }
                        .hLeading()
                        .padding(10)
                        .background(Color.gray.opacity(index == router.selectedChat ? 0.2 : 0))
                        .contentShape(Rectangle())
                        .overlay(alignment: .bottom){
                            if index != router.selectedChat{
                                Divider()
                                    .padding(.trailing, -10)
                                    .padding(.leading, 60)
                            }
                        }
                        .onTapGesture {
                            router.selectedChat = index
                        }
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
