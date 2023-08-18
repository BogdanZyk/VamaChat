//
//  DialogView+NavbarView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

extension DialogView{
    struct NavBarView: View {
        @EnvironmentObject var router: MainRouter
        @EnvironmentObject var viewModel: DialogViewModel
        private var isPrivateChat: Bool{
            viewModel.chatData.chat.chatType == .chatPrivate
        }
        var body: some View {
            VStack(alignment: .leading) {
                HStack{
                    chatInfoView
                    Spacer()
                    rightButton
                }
                .padding(.horizontal)
                .padding(.top, 10)
                Divider()
                pinMessageSection
            }
        }
    }
}


struct NavbarView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView.NavBarView()
            .environmentObject(DialogViewModel(chatData: .mocks.first!, currentUser: .mock))
    }
}

extension DialogView.NavBarView{
    
    private var chatInfoView: some View{
        Group{
            let photo = isPrivateChat ? viewModel.chatData.target?.image : viewModel.chatData.chat.photo
            AvatarView(image: isPrivateChat ? viewModel.chatData.target?.image : viewModel.chatData.chat.photo, size: .init(width: 30, height: 30))
                .onTapGesture {
                    if let photo, !photo.isEmpty{
                        let image = StorageItem(path: "", fullPath: photo)
                        router.imageViewer.set(selectedImage: image, images: [image])
                    }
                }
            VStack(alignment: .leading) {
                Text(isPrivateChat ? (viewModel.chatData.target?.fullName ?? "") : viewModel.chatData.chat.title ?? "")
                    .font(.body.bold())
                Text(viewModel.getDialogActionStr())
                    .font(.system(size: 10, weight: .light))
            }
        }
    }
    
    
    @ViewBuilder
    private var pinMessageSection: some View{
        if !viewModel.pinnedMessages.isEmpty, let lastPinMessage = viewModel.pinnedMessages.last{
            VStack{
                HStack{
                    VStack(spacing: 2){
                        ForEach(viewModel.pinnedMessages.indices, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.cyan)
                                .frame(width: 2)
                        }
                    }
                    .frame(height: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pin message")
                            .font(.system(size: 12, weight: .medium))
                        makeMessageContent(lastPinMessage.getMessage())
                    }
                    Spacer()
                    Button {
                        viewModel.pinOrUnpinMessage(message: lastPinMessage, onPinned: false)
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title3)
                            .foregroundColor(Color.cyan)
                    }
                    .buttonStyle(.plain)
                    
                }
                .padding(.horizontal)
                Divider()
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: viewModel.onTapPinMessage)
        }
    }
    
    @ViewBuilder
    private func makeMessageContent(_ message: Message) -> some View {
        if let media = message.media, !media.isEmpty, let firstItem = media.first?.item {
            HStack {
                LazyNukeImage(strUrl: firstItem.fullPath, resizeSize: .init(width: 100, height: 100), contentMode: .aspectFit, loadPriority: .high)
                    .frame(width: 20, height: 20)
                    .cornerRadius(1)
                Text("Photo \(media.count)")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.secondary)
            }
        } else if let text = message.message{
            Text(text)
                .font(.system(size: 12, weight: .light))
                .lineLimit(1)
        }
    }
}

extension DialogView.NavBarView {
    
    private var rightButton: some View {
        Group {
            if viewModel.isActiveSelectedMode{
                Button("Done") {
                    viewModel.resetSelection()
                }
            } else {
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .padding(.vertical, 5)
        .foregroundColor(.cyan)
        .buttonStyle(.plain)
    }
}
