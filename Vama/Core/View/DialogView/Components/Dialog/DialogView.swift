//
//  DialogView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI
import Algorithms

struct DialogView: View {
    @EnvironmentObject var router: MainRouter
    @State var images: [NSImage] = []
    @State var isTargeted: Bool = false
    @StateObject var viewModel: DialogViewModel
    @State var hiddenDownButton: Bool = false
    let currentUserId: String?
    var chatData: ChatConversation
    let onAppear: Bool
    init(chatData: ChatConversation,
         currentUser: User?,
         onAppear: Bool){
        self._viewModel = StateObject(wrappedValue: DialogViewModel(chatData: chatData, currentUser: currentUser))
        self.currentUserId = currentUser?.id
        self.onAppear = onAppear
        self.chatData = chatData
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                messagesList
                    .padding()
            }
            .flippedUpsideDown()
            .onChange(of: viewModel.targetMessageId) { id in
                scrollTo(proxy, id: id)
            }
            .overlay(alignment: .bottomTrailing) {
                scrollToBottomButton(proxy)
            }
            .onChange(of: viewModel.pinMessageTrigger) { _ in
                scrollTo(proxy, id: viewModel.pinnedMessages.last?.id)
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.targetMessageId)
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0){
            NavBarView()
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            BottomBarView()
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay { onDropOverlay }
        .environmentObject(viewModel)
        .animation(.easeOut(duration: 0.2), value: viewModel.bottomBarActionType.id)
        .onAppear{
            viewModel.onAppear = onAppear
        }
        .onChange(of: onAppear) { onAppear in
            viewModel.onAppear = onAppear
        }
        .onChange(of: chatData) { newValue in
            viewModel.chatData = chatData
        }
        .fileImporter(isPresented: $viewModel.showFileExporter, allowedContentTypes: [.image], allowsMultipleSelection: true, onCompletion: viewModel.selectImageFromImporter)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted, perform: viewModel.dropFiles)
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(chatData: .mocks.first!, currentUser: .mock, onAppear: false)
    }
}

extension DialogView{
   
    @ViewBuilder
    private var onDropOverlay: some View {
        if !viewModel.selectedImages.isEmpty{
            ZStack{
                Color.black.opacity(0.3)
                DropModalView(viewModel: viewModel)
            }
        } else if isTargeted{
            Color.black.opacity(0.3)
        }
    }
    
}

