//
//  ProfileView+NicknameEditView.swift
//  Vama
//
//  Created by Bogdan Zykov on 16.08.2023.
//

import SwiftUI

extension ProfileView {
    struct NicknameEditView: View {
        @ObservedObject var viewModel: ProfileViewModel
        @Environment(\.dismiss) private var dismiss
        var body: some View{
            VStack(alignment: .leading, spacing: 10){
                CustomForm {
                    TextField("Nickname", text: $viewModel.userInfo.username)
                        .textFieldStyle(.plain)
                }
                Group{
                    Text("You can choose a public name. You can be found by this name.")
                    Text("You can use the characters a-a, 0-9, minimum length 5 characters.")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
                NavigationHeaderView(title: "Edit nickname") {
                    dismiss()
                } rightItem: {
                    Button {
                        viewModel.updateUserInfo {
                            dismiss()
                        }
                    } label: {
                        if viewModel.showLoader{
                            ProgressView()
                        }else{
                            Text("Save")
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isDisabled)
                }
            }
        }
    }
}
