//
//  DropModalView.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension DialogView {
    
    struct DropModalView: View {
        @State private var onHover: Bool = false
        @ObservedObject var viewModel: DialogViewModel
        var body: some View {
            VStack(spacing: 0) {
                Image(systemName: "xmark.circle")
                    .hTrailing()
                    .foregroundColor(.cyan)
                    .padding(.vertical, 5)
                    .onTapGesture {
                        viewModel.removeImages()
                    }
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(viewModel.selectedImages) { image in
                            makeImage(image)
                        }
                    }
                    .cornerRadius(15)
                }
                Divider().padding(.horizontal, -10)
                
                dropModalTextfield
            }
            .padding(10)
            .frame(width: 280, height: 350)
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(12)
        }
        
        private var dropModalTextfield: some View {
            HStack{
                TextField("Message...", text: $viewModel.textMessage, axis: .vertical)
                    .textFieldStyle(.plain)
                Spacer()
                
                Button {
                    viewModel.send()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.cyan)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.plain)
            }
            .padding(.vertical, 10)
        }
        
        private func makeImage(_ image: ImageItem) -> some View {
            Image(nsImage: image.image)
                .resizable()
                .scaledToFit()
                .clipped()
                .overlay(alignment: .bottomTrailing) {
                    if onHover{
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.25), in: Capsule())
                            .padding(10)
                            .onTapGesture {
                                viewModel.removeImage(for: image.id)
                            }
                    }
                }
                .onHover {
                    onHover = $0
                }
        }
    }
}


struct DropModalView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView.DropModalView(viewModel: DialogViewModel(chatData: .mocks.first!, currentUser: nil))
    }
}

