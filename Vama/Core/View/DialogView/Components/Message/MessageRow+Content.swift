//
//  MessageRow+Content.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension MessageRow {
    
    @ViewBuilder
    var messageContent: some View{
        
        if let medias = dialogMessage.message.media{
           makeMedia(medias)
        }
        
        if let message = dialogMessage.message.message {
            Text(message)
                .font(.system(size: 14, weight: .light))
        }
    }
    

}
