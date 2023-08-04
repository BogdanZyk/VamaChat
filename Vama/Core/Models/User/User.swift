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
    let username: String
    let email: String?
    var profileImage: StorageItem?
    var firstName: String?
    var lastName: String?
    var bio: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case profileImage
        case lastName
        case firstName
        case bio
    }

}

extension User{
    static let mock = User(id: "fTSwHTmYHkeYvfsWASMpEDlwGmg2",
                           username: "@Tester",
                           email: "test@test.cpm",
                           profileImage: .init(path: "", fullPath: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_KIEkMvsIZEmzG7Og_h3SJ4T3HsE2rqm3_w&usqp=CAU"),
                           firstName:"Alex",
                           lastName: "Tsimikas",
                           bio: "Writer by Profession. Artist by Passion!")
}


//extension User{
//
//
//    struct UserInfo{
//        let id: String
//        var userName: String
//        var fullName: String
//        var bio: String
//
//        func getDict() -> [String: Any]{
//            [
//                User.CodingKeys.userName.rawValue: userName,
//                User.CodingKeys.fullName.rawValue: fullName,
//                User.CodingKeys.bio.rawValue: bio,
//            ]
//        }
//    }
//
////
////    func getInfo() -> UserInfo{
////        .init(id: id, userName: userName, fullName: fullName ?? "", bio: bio ?? "")
////    }
//}


extension User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}



struct ShortUser: Identifiable, Codable, Hashable{
    let id: String
    let fullName: String
    let username: String
    let image: String?
    
    
    init(user: User){
        self.id = user.id
        self.fullName = (user.firstName ?? "") + " " + (user.lastName ?? "")
        self.username = user.username
        self.image = user.profileImage?.fullPath
    }
    
    static let mock = ShortUser(user: .mock)
}
