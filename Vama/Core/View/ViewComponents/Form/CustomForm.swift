//
//  CustomForm.swift
//  Vama
//
//  Created by Bogdan Zykov on 16.08.2023.
//

import SwiftUI

struct CustomForm<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View{
        HStack(spacing: 15){
            content
        }
        .hCenter()
        .padding()
        .background(Color(nsColor: .darkGray))
        .cornerRadius(15)
    }
}

struct CustomForm_Previews: PreviewProvider {
    static var previews: some View {
        CustomForm{
            Text("Form")
        }
    }
}
