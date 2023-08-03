//
//  DialogView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI

struct DialogView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navBarView
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 10){
                        ForEach(1...30, id: \.self) { _ in
                            MessageRow(message: .mocks.first!, recipientType: .received)
                                .flippedUpsideDown()
                        }
                    }
                    .padding()
                }
                .flippedUpsideDown()
            }
        }
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView()
    }
}

extension DialogView{

    private var navBarView: some View{
        VStack(alignment: .leading) {
            HStack{
                Circle()
                    .frame(width: 30, height: 30)
                VStack(alignment: .leading) {
                    Text("User name")
                        .font(.body.bold())
                    Text("status")
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            Divider()
        }
       
    }
}
