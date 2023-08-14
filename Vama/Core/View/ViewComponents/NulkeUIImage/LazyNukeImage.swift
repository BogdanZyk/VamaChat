//
//  LazyNukeImage.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI
import NukeUI
import Nuke

struct LazyNukeImage: View {
    
    private var url: URL?
    var strUrl: String?
    var resizeSize: CGSize
    var contentMode: ImageProcessors.Resize.ContentMode
    var loadPriority: ImageRequest.Priority = .normal
    var upscale: Bool
    var crop: Bool
    private let imagePipeline = ImagePipeline(configuration: .withDataCache)
    
    init(strUrl: String?,
         resizeSize: CGSize = .init(width: 200, height: 200),
         contentMode: ImageProcessors.Resize.ContentMode = .aspectFill,
         loadPriority: ImageRequest.Priority = .normal,
         upscale: Bool = false,
         crop: Bool = true) {
        self.strUrl = strUrl
        self.resizeSize = resizeSize
        self.contentMode = contentMode
        self.loadPriority = loadPriority
        if let strUrl = strUrl{
            self.url = URL(string: strUrl)
        }
        self.crop = crop
        self.upscale = upscale
       
    }
    var body: some View {
        Group {
            if let url = url {
                LazyImage(source: url) { state in
                    if let image = state.image {
                        image
                            .aspectRatio(contentMode: contentMode == .aspectFill ? .fill : .fit)
                    }else  if state.isLoading{
                        Color.gray
                            .scaledToFill()
                    }else if let _ = state.error{
                        Color.gray
                            .scaledToFill()
                    }
                }
                .processors([ImageProcessors.Resize.resize(size: resizeSize, unit: .points, contentMode: contentMode, crop: crop, upscale: upscale)])
                .priority(loadPriority)
                .pipeline(imagePipeline)
            } else {
                Color.red
            }
        }
    }
}
