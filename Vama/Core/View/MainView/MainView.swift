//
//  MainView.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

struct MainView: View {
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
                        if let chatData = chatVM.selectedChat{
                            DialogView(chatData: chatData, onSetDraft: chatVM.onSetDraft)
                        } else {
                            Text("Choose chat")
                        }
                    case .profile:
                        Text("User Profile")
                        
                    case .settings:
                        Text("General Settings")
                    }
                    
                }
                .navigationDestination(for: String.self) { text in
                    Text(verbatim: text)
                }
            }
        }
        
//        NavigationView {
//
//            HStack(spacing: 16){
//                tabView
//
//                ZStack{
//                    switch router.currentTab{
//                    case .chats:
//                        ChatsView()
//
//                    case .profile:
//                        Text("Profile")
//                    case .settings:
//                        Text("Settings")
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
        //.ignoresSafeArea(.all)
        .frame(minWidth: getRect().width / 3, minHeight: getRect().height / 1.8)
        .environmentObject(router)
        .environmentObject(userManager)
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



