//
//  ChatModalView.swift
//  Vama
//
//  Created by Bogdan Zykov on 18.08.2023.
//

import SwiftUI

struct ChatModalView: View {
    let setter: ChatModalSetter
    @Environment(\.dismiss) private var dismiss
    let conversations: [ChatConversation]
    var body: some View {
        VStack{
            closeButton
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(conversations.sorted(by: {$0.pinned && !$1.pinned})) { conversation in
                    chatRow(conversation)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            setter.onTapChat?(conversation.id)
                            dismiss()
                        }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(idealWidth: 320, minHeight: 300)
        .cornerRadius(12)
    }
}

struct ChatModalView_Previews: PreviewProvider {
    static var previews: some View {
        ChatModalView(setter: ChatModalSetter(), conversations: ChatConversation.mocks)
    }
}


extension ChatModalView {

    @ViewBuilder
    private func chatRow(_ conversation: ChatConversation) -> some View{
         let isPrivateChat: Bool = conversation.chat.chatType == .chatPrivate
        VStack {
            HStack{
                AvatarView(image: isPrivateChat ? conversation.target?.image : conversation.chat.photo, size: .init(width: 30, height: 30))
                
                VStack(alignment: .leading) {
                    Text(isPrivateChat ? (conversation.target?.fullName ?? "") : conversation.chat.title ?? "")
                        .font(.body.bold())
                    if isPrivateChat, let status = conversation.target?.status.statusStr{
                        Text(status)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            Divider()
        }
    }
    
    private var closeButton: some View{
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle")
                .font(.title2)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .hLeading()
    }

}

struct ChatModalSetter {
    var onTapChat: ((String) -> Void)? = nil
}
