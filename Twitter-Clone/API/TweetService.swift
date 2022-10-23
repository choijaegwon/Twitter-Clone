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
        let ref = REF_TWEETS.childByAutoId()

        ref.updateChildValues(values) { err, ref in
            guard let tweetID = ref.key else { return }
            // 트윗 업로드가 완료된후 그키를 이용해 사용자 트윗 구조를 업데이트한다.
            REF_USERS_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
        }
    }
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEETS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            // Tweet에 저장되어있는 uid불러오기
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key

            // Tweet에서 유저 정보를 사용하기 위함
            UserSerivce.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USERS_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            // tweetID 키를 가지고 tweets에 접근해서 그트윗의 정보를 가져온다.
            REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                // Tweet에 저장되어있는 uid불러오기
                guard let uid = dictionary["uid"] as? String else { return }
                
                // Tweet에서 유저 정보를 사용하기 위함
                UserSerivce.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
}
