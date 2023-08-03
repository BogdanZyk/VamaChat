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
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 5){
                    ForEach(1...50, id: \.self) { index in
                        HStack(alignment: .center){
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading, spacing: 3){
                                Text("User Name")
                                    .font(.body.bold())
                                Text("Message \(index)")
                                    .font(.caption.weight(.medium))
                            }
                        }
                        .hLeading()
                        .padding(5)
                        .background(Color.gray.opacity(index == router.selectedChat ? 0.2 : 0), in: RoundedRectangle(cornerRadius: 10))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            router.selectedChat = index
                        }
                    }
                }
            }
        }
        .padding(5)
        
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
        TextField("Search", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .padding(.top, 10)
    }
}
