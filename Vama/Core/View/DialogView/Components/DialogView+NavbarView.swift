//
//  DialogView+NavbarView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

extension DialogView{
    struct NavBarView: View {
        @EnvironmentObject var viewModel: DialogViewModel
        var body: some View {
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
}


struct NavbarView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView.NavBarView()
    }
}
