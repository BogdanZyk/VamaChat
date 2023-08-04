//
//  SearchTextField.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

struct SearchTextField: View {
    @Binding var query: String
    @FocusState private var isFocused: Bool
    let onChangeFocus: (Bool) -> Void
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $query)
                .textFieldStyle(.plain)
            Spacer()
            if isFocused{
                xmarkButton
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.primary.opacity(0.15))
        .cornerRadius(10)
        .padding(10)
        .focused($isFocused)
        .onChange(of: isFocused, perform: onChangeFocus)
    }
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(query: .constant(""), onChangeFocus: {_ in})
    }
}

extension SearchTextField{
    
    private var xmarkButton: some View{
        Button {
            query.removeAll()
            isFocused = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 16))
                .opacity(0.7)
        }
        .buttonStyle(.plain)
    }
    
}
