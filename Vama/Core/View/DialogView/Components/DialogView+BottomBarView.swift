//
//  DialogView + BottomBarView.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import SwiftUI

extension DialogView{
    struct BottomBarView: View {
        @EnvironmentObject var viewModel: DialogViewModel
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                messageSelectedSection
                HStack(alignment: .bottom, spacing: 15){
                    Button {
                        viewModel.showFileExporter.toggle()
                    } label: {
                        Image(systemName: "paperclip")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    TextField("Message...", text: $viewModel.textMessage, axis: .vertical)
                        .textFieldStyle(.plain)
                    
                    sendButton
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}



struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView.BottomBarView()
            .environmentObject(DialogViewModel(chatData: .mocks.first!, currentUser: .mock))
    }
}

extension DialogView.BottomBarView{
    
    private var sendButton: some View{
        Button {
            viewModel.send()
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.title2)
                .foregroundColor((viewModel.textMessage.isEmptyStrWithSpace ? .gray : .blue))
        }
        .disabled(viewModel.textMessage.isEmptyStrWithSpace)
        .keyboardShortcut(.defaultAction)
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var messageSelectedSection: some View{
        if viewModel.bottomBarActionType.id != 2{
            HStack{
                let isEditMode = viewModel.bottomBarActionType.id == 0
                Image(systemName: isEditMode ? "pencil" : "arrowshape.turn.up.left")
                    .font(.title2)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(isEditMode ? "Edit" : viewModel.bottomBarActionType.message?.sender.fullName ?? "")
                        .font(.system(size: 14, weight: .medium))
                    Text(viewModel.bottomBarActionType.message?.message ?? "")
                        .font(.system(size: 14, weight: .light))
                }
                
                Spacer()
                
                Button {
                    viewModel.resetBottomBarAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, -5)
            .zIndex(-1)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}



