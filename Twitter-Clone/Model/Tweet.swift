//
//  Tweet.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/22.
//

import Foundation

struct Tweet {
    let caption: String
    let tweetID: String
    var likes: Int
    var timestamp: Date!
    let retweetCount: Int
    // user 속성까지 사용하기 위함
    var user: User
    var didLike = false
    var replyingTo: String?
    // TweetCell에있는 replyLabel 보여줄지말지 결정함
    var isReply: Bool {
        return replyingTo != nil
    }
    
    init(user: User, tweetID: String, dictionary: [String: Any]) {
        self.user = user
        self.tweetID = tweetID
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}
