//
//  MessageRow+ForwardMessage.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension MessageRow{
    
    func forwardMessage(message: SubMessage) -> some View {

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(message.user.fullName)
                    .font(.body.weight(.medium))
                Text("\(message.message.createdAt.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.secondary)
            }
            makeMessageContent(message.message)
        }
        .padding(.leading, 10)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.cyan)
                .frame(width: 2)
        }
    }
    
    var forwardLabel: some View {
        Text("Forwarded messages")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom, 5)
    }
}


