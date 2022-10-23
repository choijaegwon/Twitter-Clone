//
//  UserSerivce.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/21.
//

import Firebase

struct UserSerivce {
    static let shared = UserSerivce()
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        // Realtime Database에서 uid아래있는 값들 snapshot으로 다 가져오기.
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            // 그값들을 dictionary값으로 바꿔주기
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            // 모델 객체에 넣어줘서 초기화 시키기.
            let user = User(uid: snapshot.key, dictionary: dictionary)
            // 넣어준 정보를 completion을 활용해 넘겨주기.
            completion(user)
        }
    }
    
    func fetchUser(completion: @escaping([User]) -> Void) {
        var users = [User]()
        REF_USERS.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
}
