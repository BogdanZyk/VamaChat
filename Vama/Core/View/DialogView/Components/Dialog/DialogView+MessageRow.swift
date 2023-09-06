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
            onActionMessage: onActionMessage)
        
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
    
    func onActionMessage(_ action: MessageContextAction, _ message: Message) {
        viewModel.messageAction(action, message)
        if action == .forward{
            let setter: ChatModalSetter = .init(onTapChat: viewModel.forwardMessages)
            router.sheetDestination = .chatListModal(setter)
        }
    }
}
