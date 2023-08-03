//
//  LazyNukeImage.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI
import NukeUI
import Nuke

struct LazyNukeImage: View{
    
    private var url: URL?
    var strUrl: String?
    var resizeHeight: CGFloat = 200
    var resizingMode: ContentMode
    var loadPriority: ImageRequest.Priority = .normal
    private let imagePipeline = ImagePipeline(configuration: .withDataCache)
    
    init(strUrl: String?,
         resizeHeight: CGFloat = 200,
         resizingMode: ContentMode = .fill,
         loadPriority: ImageRequest.Priority = .normal){
        self.strUrl = strUrl
        self.resizeHeight = resizeHeight
        self.resizingMode = resizingMode
        self.loadPriority = loadPriority
        if let strUrl = strUrl{
            self.url = URL(string: strUrl)
        }
       
    }
    var body: some View{
        Group{
            if let url = url {
                LazyImage(source: url) { state in
                    if let image = state.image {
                        image
                        .aspectRatio(contentMode: resizingMode)
                    }else  if state.isLoading{
                        Color.gray
                    }else if let _ = state.error{
                        Color.gray
                    }
                }
                .processors([ImageProcessors.Resize.resize(height: resizeHeight)])
                .priority(loadPriority)
                .pipeline(imagePipeline)
            }else{
                Color.red
            }
        }
    }
}
