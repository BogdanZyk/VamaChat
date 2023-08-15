//
//  MainView.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var authManager: AuthenticationViewModel
    @StateObject var userManager = UserManager()
    @StateObject var router = MainRouter()
    @StateObject var chatVM = ChatViewModel()
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            tabView
                .navigationSplitViewColumnWidth(80)
                .toolbar(.hidden, for: .windowToolbar)
        } content: {
            Group {
                switch router.currentTab{
                case .chats:
                    ChatsView(chatVM: chatVM)
                case .profile:
                    ProfileView()
                case .settings:
                    Text("Settings")
                }
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 220, max: 380)
            
        } detail: {
            NavigationStack {
                ZStack {
                    switch router.currentTab{
                    case .chats:
                       currentDialogView
                    case .profile:
                        Text("User Profile")
                    case .settings:
                        VStack {
                            Text("General Settings")
                        }
                    }
                    
                }
            }
            .navigationSplitViewColumnWidth(min: 400, ideal: 600)
        }
        .frame(minWidth: getRect().width / 3, minHeight: getRect().height / 1.8)
        .environmentObject(router)
        .environmentObject(userManager)
        .onChange(of: scenePhase) { newValue in
            switch newValue{
            case .active:
                userManager.updateUserOnlineStatus(.online)
            default:
                userManager.updateUserOnlineStatus(.recently)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

extension MainView{
    private var tabView: some View{
        VStack{
            ForEach(MainTab.allCases, id: \.self) { tab in
                TabButton(tab: tab, currentTab: $router.currentTab)
            }
        }
        .vTop()
        .padding(.top, 10)
        .padding(10)
        .background(BlurView())
    }
}

extension MainView{
    
    
    @ViewBuilder
    private var currentDialogView: some View{
        if chatVM.selectedChat != nil {
            ZStack{
                ForEach(chatVM.chatConversations) { chat in
                    let onActive = chat.id == chatVM.selectedChat?.id
                    DialogView(chatData: chat,
                               currentUser: userManager.user,
                               onAppear: onActive)
                    .zIndex(onActive ? 1 : -10)
                }
            }
        }else{
            Text("Choose chat")
        }
    }
    
}


