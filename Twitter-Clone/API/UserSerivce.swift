//
//  UserSerivce.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/21.
//

import Firebase

struct UserSerivce {
    static let shared = UserSerivce()
    
    func fetchUser() {
        // Realtime Database에서 uid 가져오기.
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // Realtime Database에서 uid아래있는 값들 snapshot으로 다 가져오기.
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            // 그값들을 dictionary값으로 바꿔주기
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            // 모델 객체에 넣어줘서 초기화 시키기.
            let user = User(uid: snapshot.key, dictionary: dictionary)
            
            print("DEBUG: Username is \(user.username)")
            print("DEBUG: Fullname is \(user.fullname)")
        }
    }
}
