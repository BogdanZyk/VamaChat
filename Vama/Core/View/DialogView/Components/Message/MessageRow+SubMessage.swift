//
//  MessageRow+SubMessage.swift
//  Vama
//
//  Created by Bogdan Zykov on 18.08.2023.
//

import SwiftUI

extension MessageRow {
    
    @ViewBuilder
    var replyMessage: some View {
        if let reply = dialogMessage.message.replyMessage?.first{
            makeSubMessage(message: reply, withDateLabel: false)
        }
    }
    
    func makeForwardMessage(message: SubMessage) -> some View {
        makeSubMessage(message: message, withDateLabel: true)
    }
    
    var forwardLabel: some View {
        Text("Forwarded messages")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom, 5)
    }
    
    
    private func makeSubMessage(message: SubMessage, withDateLabel: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(message.user.fullName)
                    .font(.body.weight(.medium))
                if withDateLabel {
                    Text("\(message.message.createdAt.date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.secondary)
                }
            }
            makeMessageContent(message.message.getMessage())
        }
        .padding(.leading, 10)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.cyan)
                .frame(width: 2)
        }
    }
    
}
