//
//  DialogView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI

struct DialogView: View {
    @State var showFileExporter: Bool = false
    @State var textMessage: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navBarView
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 6, pinnedViews: .sectionFooters){
                        ForEach(1...3, id: \.self){index in
                            Section {
                                ForEach(1...30, id: \.self) { _ in
                                    MessageRow(message: .mocks.first!, recipientType: .received)
                                        .flippedUpsideDown()
                                }
                            } footer: {
                                Text(Date().toFormatDate().capitalized)
                                    .font(.footnote.weight(.medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Material.ultraThinMaterial, in: Capsule())
                                    .padding(.vertical, 5)
                                    .flippedUpsideDown()
                            }
                        }
                    }
                    .padding()
                }
                .flippedUpsideDown()
            }
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            bottomBar
        }
        .fileImporter(isPresented: $showFileExporter, allowedContentTypes: [.image]){result in
            print(result.map({$0.pathExtension}))
        }
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView()
    }
}

extension DialogView{

    private var navBarView: some View{
        VStack(alignment: .leading) {
            HStack{
                Circle()
                    .frame(width: 30, height: 30)
                VStack(alignment: .leading) {
                    Text("User name")
                        .font(.body.bold())
                    Text("status")
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            Divider()
        }
    }
    
    private var bottomBar: some View{
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            HStack(alignment: .bottom, spacing: 15){
                Button {
                    showFileExporter.toggle()
                } label: {
                    Image(systemName: "paperclip")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                TextField("Message...", text: $textMessage, axis: .vertical)
                    .textFieldStyle(.plain)
                
                sendButton
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private var sendButton: some View{
        Button {
            print("Send message \(textMessage)")
            textMessage = ""
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.title2)
                .foregroundColor((textMessage.isEmptyStrWithSpace ? .gray : .blue))
        }
        .disabled(textMessage.isEmptyStrWithSpace)
        .keyboardShortcut(.defaultAction)
        .buttonStyle(.plain)
    }
}
