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
    let currentUserId: String?
    init(chatData: ChatConversation,
         currentUser: User?,
         onSetDraft: ((String?, String) -> Void)? = nil){
        self._viewModel = StateObject(wrappedValue: DialogViewModel(chatData: chatData, currentUser: currentUser))
        self.chatData = chatData
        self.onSetDraft = onSetDraft
        self.currentUserId = currentUser?.id
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                messagesSection
                    .padding()
            }
            .flippedUpsideDown()
            .onChange(of: viewModel.targetMessageId) { id in
                scrollTo(proxy, id: id)
            }
            .overlay(alignment: .bottomTrailing) {
                downButton(proxy)
            }
            .onChange(of: viewModel.pinMessageTrigger) { _ in
                scrollTo(proxy, id: viewModel.pinnedMessages.last?.id ?? "")
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.targetMessageId)
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
        DialogView(chatData: .mocks.first!, currentUser: .mock)
    }
}


extension DialogView{
    
    private var messagesSection: some View{
        LazyVStack(spacing: 10, pinnedViews: .sectionFooters){
            let chunkedMessages = viewModel.messages.chunked(by: {$0.message.createdAt.date.isSameDay(as: $1.message.createdAt.date)})
            ForEach(chunkedMessages.indices, id: \.self){ index in
                Section {
                    ForEach(chunkedMessages[index].uniqued(on: {$0.id})) { dialogMessage in
                        MessageRow(
                            sender: viewModel.getMessageSender(senderId: dialogMessage.message.fromId),
                            currentUserId: currentUserId,
                            dialogMessage: dialogMessage,
                            onActionMessage: viewModel.messageAction)
                        
                        .id(dialogMessage.message.id)
                        .flippedUpsideDown()
                        .onAppear{
                            viewModel.viewMessage(dialogMessage.message)
                            viewModel.loadNextPage(dialogMessage.message.id)
                            hiddenOrUnhiddenDownButton(dialogMessage.message.id, hidden: true)
                        }
                        .onDisappear{
                            hiddenOrUnhiddenDownButton(dialogMessage.message.id, hidden: false)
                        }
                    }
                } footer: {
                    if let date = chunkedMessages[index].first?.message.createdAt.date{
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
            withAnimation {
                hiddenDownButton = hidden
            }
        }
    }
    
    @ViewBuilder
    private func downButton(_ proxy: ScrollViewProxy) -> some View{
        if !hiddenDownButton{
            Button {
                guard let id = viewModel.messages.first?.id else { return }
                scrollTo(proxy, id: id)
            } label: {
                Image(systemName: "chevron.down")
                    .padding(10)
                    .background(Color(nsColor: .windowBackgroundColor), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 1)
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                    .padding(.trailing, 5)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func scrollTo(_ proxy: ScrollViewProxy, id: String?){
        withAnimation {
            proxy.scrollTo(id)
        }
    }
}
