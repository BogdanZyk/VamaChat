//
//  DialogView+MessageRow.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension DialogView {
    
    func makeMessageRow(_ dialogMessage: DialogMessage, isOneByOne: Bool) -> some View{
        MessageRow(
            sender: viewModel.getMessageSender(senderId: dialogMessage.message.fromId),
            currentUserId: currentUserId,
            dialogMessage: dialogMessage,
            isShortMessage: isOneByOne,
            isActiveSelection: viewModel.isActiveSelectedMode,
            onActionMessage: viewModel.messageAction)
        
        .id(dialogMessage.message.id)
        .flippedUpsideDown()
        .onAppear{
            viewModel.viewMessage(dialogMessage.message)
            viewModel.loadNextPage(dialogMessage.message.id)
            hiddenOrUnhiddenDownButton(dialogMessage.message.id, hidden: true)
        }
        .onDisappear{
            hiddenOrUnhiddenDownButton(dialogMessage.message.id, hidden: false)
        }
    }
    
    func hiddenOrUnhiddenDownButton(_ messageId: String, hidden: Bool){
        if messageId == viewModel.messages.first?.id{
            withAnimation {
                hiddenDownButton = hidden
            }
        }
    }
}
