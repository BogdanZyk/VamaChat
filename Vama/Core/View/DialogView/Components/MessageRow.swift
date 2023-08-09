//
//  MessageBubbleView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI


struct MessageRow: View {
    let sender: ShortUser?
    let currentUserId: String?
    let dialogMessage: DialogMessage
    let isShortMessage: Bool
    let onActionMessage: (MessageContextAction, Message) -> Void
    var currentUserSender: Bool{
        sender?.id == currentUserId
    }
    
    var body: some View {
        
        Group{
            
            if let forwardMessages = dialogMessage.message.forwardMessages{
                forwardMessage(forwardMessages)
            }else if isShortMessage{
                shortMessage
            }else{
                fullMessage
            }
        }
        .foregroundColor(.white)
        .hLeading()
        .contentShape(Rectangle())
        .contextMenu{contextMenuContent}
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 4) {
            
            ForEach(Message.mocks) { message in
                MessageRow(sender: .mock, currentUserId: "1", dialogMessage: .init(message: message), isShortMessage: false){_, _ in}
            }
            //MessageRow(sender: .mock, currentUserId: "1", dialogMessage: .init(message: Message.mocks.first!), isShortMessage: true){_, _ in}
        }
        .padding()
    }
}


enum RecipientType: String, Codable, Equatable {
    case sent
    case received
}


extension MessageRow{
    private var fullMessage: some View{
        HStack(alignment: .top, spacing: 10) {
            AvatarView(image: sender?.image, size: .init(width: 30, height: 30))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 10) {
                    Text(sender?.fullName ?? "")
                        .font(.body.bold())
                    Spacer()
                    messageTimeSection
                    loaderStateView
                }
                replyMessage
                messageText
            }
        }
    }
    
    private var shortMessage: some View{
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                replyMessage
                messageText
            }
            .padding(.leading, 40)
            Spacer()
            messageTimeSection
            loaderStateView
        }
    }
    
    private var replyMessage: some View{
        Group{
            if let reply = dialogMessage.message.replyMessage?.first{
                HStack{
                    Rectangle()
                        .fill(Color.cyan)
                        .frame(width: 2, height: 30)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(reply.user.fullName)
                            .font(.body.weight(.medium))
                        Text(reply.message.message ?? "")
                            .lineLimit(1)
                            .font(.system(size: 14, weight: .light))
                    }
                }
                .padding(.bottom, 2)
            }
        }
    }
    
    private func forwardMessage(_ messages: [SubMessage]) -> some View{
        HStack(alignment: .top, spacing: 10) {
            AvatarView(image: sender?.image, size: .init(width: 30, height: 30))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 10) {
                    Text(sender?.fullName ?? "")
                        .font(.body.bold())
                    Spacer()
                    messageTimeSection
                    loaderStateView
                }
                Text("Forwarded messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)
                
                VStack(alignment: .leading, spacing: 5){
                    ForEach(messages) { message in
                        HStack(alignment: .top){
                            VStack(alignment: .leading, spacing: 0){
                                HStack{
                                    Text(message.user.fullName)
                                        .font(.body.weight(.medium))
                                    Text("\(message.message.createdAt.date.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.system(size: 10, weight: .light))
                                        .foregroundColor(.secondary)
                                }
                                Text(message.message.message ?? "")
                                    .font(.system(size: 14, weight: .light))
                            }
                        }
                    }
                }
                .padding(.leading, 10)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.cyan)
                        .frame(width: 2)
                }
            }
        }
    }
}

extension MessageRow{
    
    
    @ViewBuilder
    private var messageText: some View{
        if let message = dialogMessage.message.message{
            Text(message)
                .font(.system(size: 14, weight: .light))
        }
    }
    
    private var messageTimeSection: some View{
        HStack(spacing: 5){
            if dialogMessage.message.pinned{
                Image(systemName: "pin.fill")
                .font(.caption)
                .foregroundColor(.cyan)
            }
            if currentUserSender, dialogMessage.message.viewAllExceptSender(){
                Image("check_double")
                    .foregroundColor(.cyan)
            }
            
                
            Text("\(dialogMessage.message.createdAt.date.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 10, weight: .light))
        }
        
    }

    private var loaderStateView: some View{
        Group{
            switch dialogMessage.loadState{
            case .completed:
                EmptyView()
            case .error:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            case .sending:
                Image(systemName: "clock.fill")
                    .foregroundColor(.white.opacity(0.5))
                    
            }
        }
        .font(.caption)
    }
    
    private var contextMenuContent: some View{
        ForEach(MessageContextAction.getAllCases(isPin: dialogMessage.message.pinned, isCurrentUser: currentUserSender), id: \.self) { type in
            Button {
                onActionMessage(type, dialogMessage.message)
            } label: {
                HStack {
                    Image(systemName: type.image)
                    Text(type.title)
                }
                .foregroundColor(type == .remove ? .red : .primary)
                .padding()
            }
        }
    }
}
