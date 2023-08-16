//
//  ProfileView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationViewModel
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showAlert: Bool = false
    @State private var showImporter: Bool = false
    var body: some View {
        VStack(spacing: 20) {
            profileInfoSection
            nickNameSection
            logOutSection
            Spacer()
        }
        .padding()
        .allFrame()
        .background(Color(nsColor: .windowBackgroundColor))
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            navHeader
        }
        .onAppear {
            viewModel.setInfo(userManager.user)
        }
        .onChange(of: userManager.user, perform: viewModel.setInfo)
        .handle(error: $viewModel.error)
        .alert("Log out of the account?", isPresented: $showAlert) {
            Button("Cancel", role: .cancel, action: {})
            Button("Ok", role: .destructive, action: {authManager.singOut()})
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.image], onCompletion: viewModel.selectImageFromImporter)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserManager())
    }
}

extension ProfileView {
    
    private var profileInfoSection: some View {
        CustomForm {
            userAvatar
            VStack {
                TextField("Firt name", text: $viewModel.userInfo.firstName)
                    .textFieldStyle(.plain)
                Divider()
                TextField("Last name", text: $viewModel.userInfo.lastName)
                    .textFieldStyle(.plain)
            }
        }
    }
    
    private var nickNameSection: some View {
        CustomForm {
            VStack(spacing: 15){
                TextField("Bio", text: $viewModel.userInfo.bio)
                    .textFieldStyle(.plain)
                Divider().padding(.horizontal, -16)
                NavigationLink {
                    NicknameEditView(viewModel: viewModel)
                } label: {
                    Text("Nickname")
                    Spacer()
                    Group{
                        Text(viewModel.userInfo.username)
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.secondary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var logOutSection: some View {
        CustomForm {
            Text("Log out")
                .foregroundColor(.red)
                .hLeading()
        }
        .onTapGesture {
            showAlert.toggle()
        }
    }
    
    private var userAvatar: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let image = userManager.user?.profileImage?.fullPath {
                AvatarView(image: image, size: .init(width: 60, height: 60))
            } else {
                ZStack {
                    Color.cyan.opacity(0.5)
                    Image(systemName: "camera")
                }
            }
        }
        .clipShape(Circle())
        .frame(width: 60, height: 60)
        .onTapGesture {
            showImporter.toggle()
        }
    }
    
    private var navHeader: some View {
        NavigationHeaderView(title: "Profile") {
            Button {
                viewModel.updateUserInfo()
            } label: {
                if viewModel.showLoader{
                    ProgressView()
                        .scaleEffect(0.6)
                }else{
                    Text("Done")
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.cyan)
            .disabled(viewModel.isDisabled)
        }
    }
}


