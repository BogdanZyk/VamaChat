//
//  User.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation

import Foundation


struct User: Identifiable, Codable, Hashable{
    
    let id: String
    var userName: String
    var email: String
    var profileImage: StorageItem?
    var fullName: String?
    var bio: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName
        case email
        case profileImage
        case fullName
        case bio
    }

}

extension User{
    static let mock = User(id: "fTSwHTmYHkeYvfsWASMpEDlwGmg2",
                           userName: "Tester",
                           email: "test@test.cpm",
                           profileImage: .init(path: "", fullPath: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_KIEkMvsIZEmzG7Og_h3SJ4T3HsE2rqm3_w&usqp=CAU"),
                           fullName: "Alex Tsimikas",
                           bio: "Writer by Profession. Artist by Passion!")
}


extension User{
    
    
    struct UserInfo{
        let id: String
        var userName: String
        var fullName: String
        var bio: String
        
        func getDict() -> [String: Any]{
            [
                User.CodingKeys.userName.rawValue: userName,
                User.CodingKeys.fullName.rawValue: fullName,
                User.CodingKeys.bio.rawValue: bio,
            ]
        }
    }
    
    
    func getInfo() -> UserInfo{
        .init(id: id, userName: userName, fullName: fullName ?? "", bio: bio ?? "")
    }
}


extension User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}



struct ShortUser: Identifiable, Codable, Hashable{
    let id: String
    let name: String
    let image: String?
    
    
    init(user: User){
        self.id = user.id
        self.name = user.userName
        self.image = user.profileImage?.fullPath
    }
    
    static let mock = ShortUser(user: .mock)
}
