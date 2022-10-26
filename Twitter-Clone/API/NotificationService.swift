//
//  NotificationService.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/26.
//

import Firebase

struct NotificationService {
    static let shared = NotificationService()
    
    func uploadNotification(type: NotificationType, tweet: Tweet? = nil, user: User? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "uid": uid,
                                     "type": type.rawValue]
        
        // uploadNotification에 tweet을 넘겨주면 그 tweet.tweetID을 넣어준다.
        if let tweet = tweet {
            values["tweetID"] = tweet.tweetID
            // notifications아래 tweet.user.uid(트윗작성자) 아래 childByAutoId자동으로 id생성해주는데
            // 그아래에 values값을 updateChildValues 해준다. 여기서 values값은 timestamp, uid, type, tweetID 이다.
            REF_NOTIFICATIONS.child(tweet.user.uid).childByAutoId().updateChildValues(values)
        } else if let user = user {
            // notifications아래 user.uid(보고있는 사용자)아래에 childByAutoId자동으로 id생성해주고
            // 그아래에 values값을 updateChildValues 해준다. 여기서 values값은 timestamp, type, uid 이다.
            REF_NOTIFICATIONS.child(user.uid).childByAutoId().updateChildValues(values)
        }
    }
}
