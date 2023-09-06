//
//  DialogView + BottomBarView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

extension DialogView{
    struct BottomBarView: View {
        @EnvironmentObject var router: MainRouter
        @EnvironmentObject var viewModel: DialogViewModel
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                Grid {
                    if viewModel.isActiveSelectedMode{
                        selectionMode
                    }else{
                        textFieldMode
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .animation(.easeIn(duration: 0.15), value: viewModel.isActiveSelectedMode)
        }
    }
}



struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView.BottomBarView()
            .environmentObject(DialogViewModel(chatData: .mocks.first!, currentUser: .mock))
            .environmentObject(MainRouter())
    }
}


extension DialogView.BottomBarView {
    
    private var selectionMode: some View {
        HStack{
            Button {
                viewModel.removeSelectedMessages()
            } label: {
                Label("Remove", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            Spacer()
            
            Button {
                let setter: ChatModalSetter = .init(onTapChat: { viewModel.forwardMessages(for: $0) })
                router.sheetDestination = .chatListModal(setter)
            } label: {
                Label {
                    Image(systemName: "arrowshape.turn.up.forward")
                } icon: {
                    Text("Forward")
                }
                .foregroundColor(.cyan)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 2)
        .overlay(alignment: .center) {
            Text("Selected \(viewModel.messages.filter({$0.selected}).count) messages")
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    @ViewBuilder
    private var textFieldMode: some View {
        messageSelectedSection
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
    }
}

extension DialogView.BottomBarView {
    
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
    
    @ViewBuilder
    private var messageSelectedSection: some View{
        if viewModel.bottomBarActionType.id != 2{
            HStack{
                let isEditMode = viewModel.bottomBarActionType.id == 0
                Image(systemName: isEditMode ? "pencil" : "arrowshape.turn.up.left")
                    .font(.title2)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(isEditMode ? "Edit" : viewModel.getMessageSender(senderId: viewModel.bottomBarActionType.message?.fromId ?? "")?.fullName ?? "")
                        .font(.system(size: 14, weight: .medium))
                    message
                }
                
                Spacer()
                
                Button {
                    viewModel.resetBottomBarAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, -5)
            .zIndex(-1)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private var message: some View{
        Group{
            if let message = viewModel.bottomBarActionType.message?.getMessage(){
                HStack{
                    if let image = message.media?.first?.item{
                        LazyNukeImage(strUrl: image.fullPath, resizeSize: .init(width: 100, height: 100), contentMode: .aspectFit, loadPriority: .low)
                            .frame(width: 20, height: 20)
                    }
                    if let text = message.message{
                        Text(message.message ?? "")
                    }
                }
            }
        }
        .font(.system(size: 14, weight: .light))
    }
}



