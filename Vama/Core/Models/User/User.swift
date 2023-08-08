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
    var createdAt = FBTimestamp()
    var profileImage: StorageItem?
    var firstName: String?
    var lastName: String?
    var bio: String?
    var status = OnlineStatus()
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case createdAt
        case email
        case profileImage
        case lastName
        case firstName
        case bio
        case status
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


extension User{


    struct UserInfo{
        let id: String
        var username: String
        var firstName: String
        var lastName: String
        var bio: String

        func getDict() -> [String: Any]{
            [
                User.CodingKeys.username.rawValue: username,
                User.CodingKeys.firstName.rawValue: firstName,
                User.CodingKeys.lastName.rawValue: lastName,
                User.CodingKeys.bio.rawValue: bio,
            ]
        }
    }


    func getInfo() -> UserInfo{
        .init(id: id, username: username, firstName: firstName ?? "", lastName: lastName ?? "", bio: bio ?? "")
    }
}


extension User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

extension User{
    func getShortUser() -> ShortUser{
        ShortUser(user: self)
    }
}

struct OnlineStatus: Codable, Hashable{
    var time = FBTimestamp()
    var isOnline: Bool = true
    var chatStatus: Status? = Status()
    
    
    struct Status: Codable, Hashable{
        
        var forChatId: String = ""
        var status: Status = .empty
        
        enum Status: String, Codable{
            case typing = "TYPING"
            case empty = "EMPTY"
            case upload = "UPLOAD"
        }
    }
}




struct ShortUser: Identifiable, Codable, Hashable{
    let id: String
    let fullName: String
    let username: String
    let image: String?
    var status: OnlineStatus
    
    
    init(user: User){
        self.id = user.id
        self.fullName = (user.firstName ?? user.username) + " " + (user.lastName ?? "")
        self.username = user.username
        self.image = user.profileImage?.fullPath
        self.status = user.status
    }
    
    static let mock = ShortUser(user: .mock)
}
