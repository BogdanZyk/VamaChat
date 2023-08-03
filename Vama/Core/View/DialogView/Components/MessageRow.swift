//
//  MessageBubbleView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI


struct MessageRow: View {
    let message: Message
    let recipientType: RecipientType
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .fill(Color.gray)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                HStack {
                    Text("User name")
                        .font(.body.bold())
                    Spacer()
                    Text("\(message.createdAt, formatter: Date.hoursAndMinuteFormatter)")
                        .font(.system(size: 10, weight: .light))
                }
                if let message = message.message{
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
            MessageRow(message: Message.mocks.first!, recipientType: .received)
            MessageRow(message: Message.mocks.first!, recipientType: .sent)
        }
        .padding()
    }
}






enum RecipientType: String, Codable, Equatable {
    case sent
    case received
}

