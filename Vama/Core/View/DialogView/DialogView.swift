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
    
    init(chatId: String){
        self._viewModel = StateObject(wrappedValue: DialogViewModel(chatId: chatId))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navBarView
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    messagesSection
                        .padding()
                }
                .flippedUpsideDown()
            }
            .animation(.easeOut(duration: 0.2), value: viewModel.sendCounter)
            
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            BottomBarView()
        }
        .fileImporter(isPresented: $viewModel.showFileExporter, allowedContentTypes: [.image]){result in
            print(result.map({$0.pathExtension}))
        }
        .environmentObject(viewModel)
        .animation(.easeOut(duration: 0.2), value: viewModel.bottomBarActionType.id)
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(chatId: "")
    }
}


extension DialogView{
    
    private var messagesSection: some View{
        LazyVStack(spacing: 6, pinnedViews: .sectionFooters){
            let chunkedMessages = viewModel.messages.chunked(by: {$0.message.createdAt.isSameDay(as: $1.message.createdAt)})
            ForEach(chunkedMessages.indices, id: \.self){ index in
                Section {
                    ForEach(chunkedMessages[index]) { dialogMessage in
                        MessageRow(dialogMessage: dialogMessage, recipientType: dialogMessage.message.getRecipientType(currentUserId: "1"))
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
    
    private var bottomBar: some View{
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            HStack(alignment: .bottom, spacing: 15){
                Button {
                    viewModel.showFileExporter.toggle()
                } label: {
                    Image(systemName: "paperclip")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                TextField("Message...", text: $viewModel.textMessage, axis: .vertical)
                    .textFieldStyle(.plain)
                
                sendButton
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private var sendButton: some View{
        Button {
            viewModel.send()
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.title2)
                .foregroundColor((viewModel.textMessage.isEmptyStrWithSpace ? .gray : .blue))
        }
        .disabled(viewModel.textMessage.isEmptyStrWithSpace)
        .keyboardShortcut(.defaultAction)
        .buttonStyle(.plain)
    }
}


extension DialogView{
    private func hiddenOrUnhiddenDownButton(_ messageId: String, hidden: Bool){
        if messageId == viewModel.messages.first?.id{
            hiddenDownButton = hidden
        }
    }
}
