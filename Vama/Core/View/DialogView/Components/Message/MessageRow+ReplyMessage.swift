//
//  MessageRow+ReplyMessage.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension MessageRow{
    var replyMessage: some View{
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
}
