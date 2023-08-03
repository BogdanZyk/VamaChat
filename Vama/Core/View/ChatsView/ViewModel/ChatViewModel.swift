//
//  ChatViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation


final class ChatViewModel: ObservableObject{
    
    @Published var chats: [Chat] = Chat.mocks
    @Published var selectedChat: Chat?
   
    
}
