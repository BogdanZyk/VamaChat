//
//  MessageBubbleView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI


struct MessageRow: View {
    @EnvironmentObject var router: MainRouter
    let sender: ShortUser?
    let currentUserId: String?
    let dialogMessage: DialogMessage
    let isShortMessage: Bool
    let isActiveSelection: Bool
    let onActionMessage: (MessageContextAction, Message) -> Void
    var currentUserSender: Bool{
        sender?.id == currentUserId
    }
    
    var body: some View {
        Group{
            if isShortMessage{
                shortVersion
            }else{
                fullVersion
            }
        }
        .foregroundColor(.white)
        .hLeading()
        .padding(.vertical, 5)
        .background(dialogMessage.selected ?  Color.gray.opacity(0.15).padding(.horizontal, -16) : nil)
        .contentShape(Rectangle())
        .contextMenu{contextMenuContent}
        .onTapGesture {
            if isActiveSelection{
                onActionMessage(.select, dialogMessage.message)
            }
        }
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ForEach(Message.mocks) { message in
                MessageRow(
                    sender: .mock,
                    currentUserId: "1", dialogMessage: .init(message: message),
                    isShortMessage: false,
                    isActiveSelection: true){_, _ in}
            }
            MessageRow(sender: .mock, currentUserId: "1", dialogMessage: .init(message: Message.mocks.first!), isShortMessage: true, isActiveSelection: false){_, _ in}
        }
        .padding()
    }
}

extension MessageRow{
    private var fullVersion: some View{
        HStack(alignment: .top, spacing: 10) {
            AvatarView(image: sender?.image, size: .init(width: 30, height: 30))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 10) {
                    Text(sender?.fullName ?? "")
                        .font(.body.bold())
                    Spacer()
                    messageRightSection
                }
                if let forwardedMessage = dialogMessage.message.forwardMessages?.first{
                    forwardLabel
                    forwardMessage(message: forwardedMessage)
                }else{
                    replyMessage
                    makeMessageContent(dialogMessage.message)
                }
            }
        }
    }
    
    private var shortVersion: some View{
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                if let forwardedMessage = dialogMessage.message.forwardMessages?.first{
                    forwardMessage(message: forwardedMessage)
                }else{
                    replyMessage
                    makeMessageContent(dialogMessage.message)
                }
            }
            .padding(.leading, 40)
            Spacer()
            messageRightSection
        }
    }
}

extension MessageRow{
        
    private var messageRightSection: some View{
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
            
            if isActiveSelection{
                Image(systemName: dialogMessage.selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.cyan)
            }
            
            loaderStateView
        }
        .animation(.easeIn(duration: 0.2), value: isActiveSelection)
        .onTapGesture{
            onActionMessage(.select, dialogMessage.message)
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
