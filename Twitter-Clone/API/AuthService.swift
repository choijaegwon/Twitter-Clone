//
//  AuthService.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/21.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    // 회원가입
    func registerUser(credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void) {
        let email = credentials.email
        let password = credentials.password
        let username = credentials.username
        let fullname = credentials.fullname
        // 이미지를 jpeg로 압축하기
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        // 파일이름을 uuid로 만들어주기
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        storageRef.putData(imageData, metadata: nil) { meta, error in
            storageRef.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                // 파이어베이스에 회원가입
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("DEBUG: Error is \(error.localizedDescription)")
                        return
                    }
                    
                    // 사용자의 User UID
                    guard let uid = result?.user.uid else { return }
                    
                    // 저장할 값을 딕셔너리형태로 만들어준다.
                    let values = ["email": email,
                                  "username": username,
                                  "fullname": fullname,
                                  "profileImageUrl": profileImageUrl]
                    
                    // REF_USERS란? 저장할 경로 Database.database().reference()까진 같고,
                    // 그뒤 "user"란 키를 추가할건데 그걸 .child(uid)에 추가할 것이다. -> REF_USERS.child(uid)로 변경
                    // 추가하는 메서드 .updateChildValues이고, values을 넣어준다.
                    REF_USER_USERNAMES.updateChildValues([username: uid])
                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                }
            }
        }
    }
}
