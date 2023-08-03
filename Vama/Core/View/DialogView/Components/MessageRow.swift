//
//  MessageBubbleView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI


struct MessageRow: View {
    let dialogMessage: DialogMessage
    let recipientType: RecipientType
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            AvatarView(image: dialogMessage.message.sender.image, size: .init(width: 30, height: 30))
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Text(dialogMessage.message.sender.name)
                        .font(.body.bold())
                    Spacer()
                    Text("\(dialogMessage.message.createdAt, formatter: Date.hoursAndMinuteFormatter)")
                        .font(.system(size: 10, weight: .light))
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
        .contextMenu {
            Button("Remove", action: {})
        }
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 4) {
            MessageRow(dialogMessage: .init(message: Message.mocks.first!), recipientType: .received)
            MessageRow(dialogMessage: .init(message: Message.mocks.first!), recipientType: .sent)
        }
        .padding()
    }
}


enum RecipientType: String, Codable, Equatable {
    case sent
    case received
}

extension MessageRow{

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
}
