//
//  StorageManager.swift
//  Vama
//
//  Created by Bogdan Zykov on 14.08.2023.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore


final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    
    private func getPath(_ path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    private func getFullPathUrl(path: String) async throws -> URL {
        try await getPath(path).downloadURL()
    }
    
    private func uploadImage(_ data: Data, type: ImageType, id: String) async throws -> StorageItem {
        let meta = StorageMetadata()
        meta.contentType = "image/jpg"
        let name = "\(UUID().uuidString).jpg"
        let returnedData = try await type.getRef(for: id).child(name).putDataAsync(data, metadata: meta)
        
        guard let path = returnedData.path else {
            throw AppError.custom(errorDescription: "Failed upload image")
        }
        try Task.checkCancellation()
        let fullPath = try await getFullPathUrl(path: path)
        
        return .init(path: path, fullPath: fullPath.absoluteString)
    }
      
    func downloadFile(from path: String, to localURL: URL) -> StorageDownloadTask {
        return storage.child(path).write(toFile: localURL)
    }
    
    func uploadMessagePhotoMedia(images: [MessageMedia], chatId: String) async throws -> [MessageMedia]{
        var medias: [MessageMedia] = []
        for try await item in SomeAsyncSequence(elements: images) {
            guard let image = item.thumbnail else { continue }
            let item = try await uploadImage(image: image, type: .messageImage, id: chatId)
            medias.append(.init(type: .image, item: item))
        }
        return medias
    }
    
    func uploadImage(image: NSImage, type: ImageType, id: String, lastImagePath: String? = nil) async throws -> StorageItem {
        //let resizeImage = image.aspectFittedToHeight(type.size)
        guard let data = image.imageDataRepresentation(compressionFactor: type.quality) else {
            throw AppError.custom(errorDescription: "Failed compression image")
        }
        
        if let lastImagePath {
            try? await deleteAsset(path: lastImagePath)
        }
        
        return try await uploadImage(data as Data, type: type, id: id)
    }
    
    func deleteAsset(path: String) async throws {
        try await getPath(path).delete()
    }
}

extension StorageManager {
    
    enum ImageType: Int {
        case avatar, messageImage
        
        func getRef(for id: String) -> StorageReference {
            let storage = StorageManager.shared.storage
            switch self {
            case .avatar: return storage.child("users").child(id)
            case .messageImage: return storage.child("chat").child(id).child("images")
            }
        }
        
        var size: CGFloat {
            switch self {
            case .avatar: return 80
            case .messageImage: return 100
            }
        }
        
        var quality: CGFloat {
            switch self {
            case .avatar: return 0.5
            case .messageImage: return 0.9
            }
        }
    }
}

//struct StoreImage: Identifiable, Codable, Hashable{
//    let path: String
//    let fullPath: String
//    
//    func getData() throws -> [String : Any]{
//        try Firestore.Encoder().encode(self)
//    }
//    
//    var id: String{ path }
//}


struct SomeAsyncSequence<T: Hashable>: AsyncSequence {
    let elements: [T]
    typealias Element = T
    
    struct AsyncCommandIterator: AsyncIteratorProtocol {
        
        typealias Element = T
        
        var arrayIterator: IndexingIterator<[T]>
        
        mutating func next() async throws -> Element? {
            guard let element = arrayIterator.next() else { return nil }
            return element
        }
    }
    
    func makeAsyncIterator() -> AsyncCommandIterator {
        AsyncCommandIterator(arrayIterator: elements.makeIterator())
    }
}
