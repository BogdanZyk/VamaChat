//
//  NSImage.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import SwiftUI

extension NSImage {
    func imageDataRepresentation(compressionFactor: CGFloat = 0.9) -> NSData? {
        if let imageTiffData = self.tiffRepresentation, let imageRep = NSBitmapImageRep(data: imageTiffData) {
            let imageProps = [NSBitmapImageRep.PropertyKey.compressionFactor: compressionFactor]
            let imageData = imageRep.representation(using: .jpeg, properties: imageProps) as NSData?
            return imageData
        }
        return nil
    }
}
