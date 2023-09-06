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
                    .frame(maxWidth: 300, maxHeight: 450)
            }else{
                singleMedia(medias)
                    .frame(maxWidth: 200, maxHeight: 300)
            }
        }
    }
    
    @ViewBuilder
    private func singleMedia(_ medias: [MessageMedia]) -> some View{
        if let media = medias.first{
            if media.type == .image{
                makeMessagePhoto(media: media, loadState: dialogMessage.loadState, isAlbum: false)
                    .onTapGesture {
                        router.imageViewer.set(selectedImage: media.item, images: medias.compactMap({$0.item}))
                    }
            }else{
                Text("Video")
            }
        }
    }
    
    private func messageMediaAlbum(_ medias: [MessageMedia]) -> some View{
        VStack(alignment: .leading, spacing: 2) {
            ForEach(medias) { item in
                if item.type == .image{
                    makeMessagePhoto(media: item, loadState: dialogMessage.loadState, isAlbum: true)
                        .onTapGesture {
                            router.imageViewer.set(selectedImage: item.item, images: medias.compactMap({$0.item}))
                        }
                }else{
                    Text("Video")
                }
            }
        }
        .padding(.horizontal, -2)
    }
    
    
    @ViewBuilder
    private func makeMessagePhoto(media: MessageMedia, loadState: DialogMessage.LoadState, isAlbum: Bool) -> some View{
        ZStack{
            if loadState == .completed {
                if !isAlbum{
                    Color.white.opacity(0.8)
                }
                LazyNukeImage(strUrl: media.item?.fullPath, resizeSize: .init(width: 600, height: 800), contentMode: .aspectFit, loadPriority: .normal, crop: false)
            } else if loadState == .sending, let image = media.thumbnail {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                Color.black.opacity(0.2)
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.1)
            }
        }
        .cornerRadius(5)
        .padding(2)
    }
}

