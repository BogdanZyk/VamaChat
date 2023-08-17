//
//  ImageViewer.swift
//  Vama
//
//  Created by Bogdan Zykov on 17.08.2023.
//

import SwiftUI

struct ImageViewerView: View {
    @EnvironmentObject var router: MainRouter
    var body: some View {
        ZStack{
            BlurView()
                .onTapGesture {
                    router.imageViewer.close()
                }
            if let image = router.imageViewer.selectedImage{
                LazyNukeImage(strUrl: image.fullPath, resizeSize: .init(width: 1920, height: 1080), contentMode: .aspectFit, loadPriority: .high, upscale: true, crop: false)
                    .padding(60)
            }
        }
        .allFrame()
    }
}
//
//struct ImageViewerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageViewerView(viewer: .constant(.init(selectedImage: nil, images: [.init(path: "", fullPath: "https://www.russiadiscovery.ru/storage/orig/posts/1038/Kavkazskie_gory.jpg")])))
//    }
//}



struct ImageViewer {
    
    var show: Bool = false
    var selectedImage: StorageItem? = nil
    var images: [StorageItem] = []
    var index: Int = 0
    

    mutating func set(selectedImage: StorageItem?, images: [StorageItem]){
        self.selectedImage = selectedImage
        self.images = images
        self.index = images.firstIndex(where: {$0.id == selectedImage?.id}) ?? 0
        show = true
    }
    
    mutating func close(){
        show = false
        self.selectedImage = nil
        self.images = []
    }
}
