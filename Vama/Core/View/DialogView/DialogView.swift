//
//  DialogView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI
import Algorithms

struct DialogView: View {
    
    @StateObject private var viewModel: DialogViewModel
    @State private var hiddenDownButton: Bool = false
    let chatData: ChatConversation
    var onSetDraft: ((String?, String) -> Void)?
    init(chatData: ChatConversation, onSetDraft: ((String?, String) -> Void)? = nil){
        self._viewModel = StateObject(wrappedValue: DialogViewModel(chatData: chatData))
        self.chatData = chatData
        self.onSetDraft = onSetDraft
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                messagesSection
                    .padding()
            }
            .flippedUpsideDown()
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.sendCounter)
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0){
            NavBarView()
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            BottomBarView()
        }
        .environmentObject(viewModel)
        .animation(.easeOut(duration: 0.2), value: viewModel.bottomBarActionType.id)
        .fileImporter(isPresented: $viewModel.showFileExporter, allowedContentTypes: [.image]){result in
            print(result.map({$0.pathExtension}))
        }
        .onChange(of: chatData) {
            if !viewModel.textMessage.isEmptyStrWithSpace{
                onSetDraft?(viewModel.textMessage, viewModel.chatData.id)
            }
            viewModel.setChatDataAndRefetch(chatData: $0)
        }
        .onChange(of: viewModel.textMessage) { newValue in
            if newValue.isEmpty, viewModel.chatData.draftMessage != nil{
                onSetDraft?(nil, chatData.id)
            }
        }
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(chatData: .mocks.first!)
    }
}


extension DialogView{
    
    private var messagesSection: some View{
        LazyVStack(spacing: 6, pinnedViews: .sectionFooters){
            let chunkedMessages = viewModel.messages.chunked(by: {$0.message.createdAt.isSameDay(as: $1.message.createdAt)})
            ForEach(chunkedMessages.indices, id: \.self){ index in
                Section {
                    ForEach(chunkedMessages[index]) { dialogMessage in
                        MessageRow(
                            dialogMessage: dialogMessage,
                            recipientType: dialogMessage.message.getRecipientType(currentUserId: "1"),
                            onActionMessage: viewModel.messageAction)
                        
                        .id(dialogMessage.message.id)
                        .flippedUpsideDown()
                        .onAppear{
                            viewModel.viewMessage(dialogMessage.message.id)
                            viewModel.loadNextPage(dialogMessage.message.id)
                            hiddenOrUnhiddenDownButton(dialogMessage.message.id, hidden: true)
                        }
                        .onDisappear{
                            hiddenOrUnhiddenDownButton(dialogMessage.message.id, hidden: false)
                            }
                    }
                } footer: {
                    if let date = chunkedMessages[index].first?.message.createdAt{
                        messagesDateLabel(date)
                    }
                }
            }
        }
    }
    
    private func messagesDateLabel(_ date: Date) -> some View{
        Text(date.toFormatDate().capitalized)
            .font(.footnote.weight(.medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Material.ultraThinMaterial, in: Capsule())
            .padding(.vertical, 5)
            .flippedUpsideDown()
    }
    
}

extension DialogView{
    private func hiddenOrUnhiddenDownButton(_ messageId: String, hidden: Bool){
        if messageId == viewModel.messages.first?.id{
            hiddenDownButton = hidden
        }
    }
}
