//
//  AvatarView.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import SwiftUI

struct AvatarView: View {
    let image: String?
    var size: CGSize = .init(width: 138, height: 138)
    var body: some View {
        Group{
            if let image{
                LazyNukeImage(strUrl: image, contentMode: .aspectFill, loadPriority: .high)
            }else{
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(Circle())
    }
}

struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AvatarView(image: User.mock.profileImage!.fullPath)
            AvatarView(image: nil)
        }
    }
}
