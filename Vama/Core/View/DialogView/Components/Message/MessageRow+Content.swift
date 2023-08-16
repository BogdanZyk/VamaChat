//
//  MessageRow+Content.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension MessageRow {
    
    @ViewBuilder
    func makeMessageContent(_ message: Message) -> some View {
        
        if let medias = message.media, !medias.isEmpty {
           makeMedia(medias)
        }
        
        if let message = message.message {
            Text(message)
                .font(.system(size: 14, weight: .light))
        }
    }
    

}
