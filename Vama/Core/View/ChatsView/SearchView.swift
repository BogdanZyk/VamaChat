//
//  SearchView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

struct SearchListView: View {
    let users: [ShortUser]
    let state: SearchViewState
    let onTap: (ShortUser) -> Void
    var body: some View {
        
        switch state {
        case .empty:
            Text("Empty result")
                .allFrame()
        case .loading:
            loader
        case .loaded:
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading, spacing: 0){
                    ForEach(users) { user in
                        rowView(user)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchListView(users: [ShortUser.mock], state: .empty, onTap: {_ in})
    }
}

extension SearchListView{
    
    private func rowView(_ user: ShortUser) -> some View{
        HStack{
            AvatarView(image: user.image, size: .init(width: 30, height: 30))
            VStack(alignment: .leading){
                Text(user.fullName)
                    .font(.system(size: 12, weight: .medium))
                Text(user.username ?? "")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(user)
        }
    }
  
    private var loader: some View{
        ProgressView()
            .allFrame()
    }
}
