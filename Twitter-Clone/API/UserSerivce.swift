//
//  UserSerivce.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/21.
//

import Firebase

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)

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
    
    func followUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // user-following에 로그인한 사용자의 자식으로 보고있는 사람 uid로 추가를 하고,
        REF_USERS_FOLLOWING.child(currentUid).updateChildValues([uid: 1]) { err, ref in
            // user-followers에 보고있는 uid아래에 로그인한사람의 currentUid를 추가해준다.
            REF_USERS_FOLLOWERS.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // 우선 user-following에 현재로그인한사용자의 아래있는 보고있는 uid를 제거하고, 그뒤
        REF_USERS_FOLLOWING.child(currentUid).child(uid).removeValue { err, ref in
            // user-followers에 보고있는 uid아래 현재로그인한 사용자의 currentUid를 제거한다.
            REF_USERS_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // user-following안 사용자의 uid아래에 받아온 uid(내가보고있는사람)가 있는지 확인
        REF_USERS_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { snapshot in
            // 그 uid가 존재하면 true 존재하지않으면 false
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(uid: String, completion: @escaping(UserRelationStats) -> Void) {
        // user-follower안 해당 uid 아래 모든 children(값들)을 개수를 새줘
        REF_USERS_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            let followers = snapshot.children.allObjects.count
            
            // user-following안 해당 uid 아래 모든 children(값들)을 개수를 새줘
            REF_USERS_FOLLOWING.child(uid).observeSingleEvent(of: .value) { snapshot in
                let following = snapshot.children.allObjects.count
                
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
    
    func updateProfileImage(image: UIImage, completion: @escaping(URL?) -> Void) {
        // 사진 데이터 변환
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let filename = NSUUID().uuidString
        // 업로드경로
        let ref = STORAGE_PROFILE_IMAGES.child(filename)
        
        // 이미지 업로드하기
        ref.putData(imageData, metadata: nil) { meta, error in
            ref.downloadURL { url, error in
                // 프로필url얻고
                guard let profileImageUrl = url?.absoluteString else { return }
                // 값에 넣어서
                let values = ["profileImageUrl": profileImageUrl]
                
                // 업데이트해주기
                REF_USERS.child(uid).updateChildValues(values) { err, ref in
                    completion(url)
                }
            }
        }
    }
    
    func saveUserData(user: User, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["fullname": user.fullname, "username": user.username, "bio": user.bio ?? ""]
        
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func fetchUser(withUsername username: String, completion: @escaping(User) -> Void) {
        REF_USER_USERNAMES.child(username).observeSingleEvent(of: .value) { snapshot in
            guard let uid = snapshot.value as? String else { return }
            self.fetchUser(uid: uid, completion: completion)
        }
    }
}
