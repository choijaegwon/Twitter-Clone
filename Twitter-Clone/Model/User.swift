//
//  User.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/21.
//

import Foundation
import Firebase

struct User {
    let fullname: String
    let email: String
    let username: String
    var profileImageUrl: URL?
    let uid: String
    // 사용자가 팔로우 하는지 안하는지 확인하는 변수.
    var isFollowed = false
    // 사용자를 가져온 후에만 사용할수 있어서 따로 지정해줌.
    var stats: UserRelationStats?
    var bio: String?
    
    // 로그인한 사용자인지 아닌지 확인해주는 변수
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            // 주소문자열을 URL로 바꿔주기.
            guard let url = URL(string: profileImageUrlString) else { return }
            // url값 넣어주기
            self.profileImageUrl = url
        }
    }
}

struct UserRelationStats {
    var followers: Int
    var following: Int
}
