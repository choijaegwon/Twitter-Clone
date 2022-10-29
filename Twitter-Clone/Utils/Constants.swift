//
//  Constants.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/21.
//

import Firebase

// 저장할 경로 Storage.storage().reference()
// profile_images란 폴더를 추가해준다. 그후
// .putData 란 메서드를 이용해서 이미지를 넘겨주고
// downloadURL를 사용해서 profileImageUrl를 얻어온다.
let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

// 저장할 경로 Database.database().reference()까진 같고,
// 그뒤 "users"란 키를 추가할건데 그걸 .child(uid)에 추가할 것이다. -> REF_USERS.child(uid)로 변경
// 추가하는 메서드 .updateChildValues이고, values을 넣어준다.
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("uesrs")
let REF_TWEETS = DB_REF.child("tweets")
let REF_USERS_TWEETS = DB_REF.child("user-tweets")
let REF_USERS_FOLLOWERS = DB_REF.child("user-followers")
let REF_USERS_FOLLOWING = DB_REF.child("user-following")
let REF_TWEET_REPLIES = DB_REF.child("tweet-replies")
let REF_USER_LIKES = DB_REF.child("user-likes")
let REF_TWEET_LIKES = DB_REF.child("tweet-likes")
let REF_NOTIFICATIONS = DB_REF.child("notifications")
let REF_USER_REPLIES = DB_REF.child("user-replies")
let REF_USER_USERNAMES = DB_REF.child("user-username")
