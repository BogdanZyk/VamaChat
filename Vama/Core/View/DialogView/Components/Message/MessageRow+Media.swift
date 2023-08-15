//
//  MessageRow+Photo.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension MessageRow{
    
    
    func makeMedia(_ medias: [MessageMedia]) -> some View{
        Group{
            if medias.count > 1{
                messageMediaAlbum(medias)
            }else{
                singleMedia(medias.first)
            }
        }
        .frame(minWidth: 150, idealWidth: 180, maxWidth: 300, maxHeight: 600)
    }
    
    @ViewBuilder
    private func singleMedia(_ media: MessageMedia?) -> some View{
        if let media{
            if media.type == .image{
                makeMessagePhoto(media: media, loadState: dialogMessage.loadState)
            }else{
                Text("Video")
            }
        }
    }
    
    private func messageMediaAlbum(_ medias: [MessageMedia]) -> some View{
        MediaAlbum {
            ForEach(medias) { item in
                if item.type == .image{
                    makeMessagePhoto(media: item, loadState: dialogMessage.loadState)
                }else{
                    Text("Video")
                }
            }
        }
        .padding(.horizontal, -2)
    }
    
    
    @ViewBuilder
    private func makeMessagePhoto(media: MessageMedia, loadState: DialogMessage.LoadState) -> some View{
        ZStack{
            if loadState == .completed {
                LazyNukeImage(strUrl: media.item?.fullPath, resizeSize: .init(width: 600, height: 800), contentMode: .aspectFit, loadPriority: .normal, crop: false)
            } else if loadState == .sending, let image = media.thumbnail {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                Color.black.opacity(0.2)
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
            }
        }
        .cornerRadius(5)
        .padding(2)
    }
}
