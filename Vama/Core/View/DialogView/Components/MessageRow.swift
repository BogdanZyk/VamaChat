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
    let onActionMessage: (MessageContextAction, Message) -> Void
    
    var currentUserSender: Bool{
        sender?.id == currentUserId
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            AvatarView(image: sender?.image, size: .init(width: 30, height: 30))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 10) {
                    Text(sender?.fullName ?? "")
                        .font(.body.bold())
                    Spacer()
                    messageTimeSection
                    loaderStateView
                }
                if let message = dialogMessage.message.message{
                    Text(message)
                        .font(.system(size: 14, weight: .light))
                }
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
            MessageRow(sender: .mock, currentUserId: "1", dialogMessage: .init(message: Message.mocks.first!)){_, _ in}
            MessageRow(sender: .mock, currentUserId: "1", dialogMessage: .init(message: Message.mocks.first!)){_, _ in}
        }
        .padding()
    }
}


enum RecipientType: String, Codable, Equatable {
    case sent
    case received
}

extension MessageRow{
    
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
            
                
            Text("\(dialogMessage.message.createdAt.date, formatter: Date.hoursAndMinuteFormatter)")
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
