//
//  TweetService.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/21.
//

import Firebase

struct TweetService {
    static let shared = TweetService()
    
    func uploadTwwet(caption: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        // 현재 사용자 uid 가져오기
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 업로드할 구조
        let values = ["uid": uid,
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String : AnyObject]
        
        // childByAutoId -> 자동으로 id부여 후 딕셔너리구조로 넣기, 그리고 completion(완료후 나머진 거기서 직접설정해!)
        REF_TWEETS.childByAutoId().updateChildValues(values, withCompletionBlock: completion)
    }
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEETS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let tweetID = snapshot.key
            let tweet = Tweet(tweetID: tweetID, dictionary: dictionary)
            tweets.append(tweet)
            completion(tweets)
        }
    }
}
