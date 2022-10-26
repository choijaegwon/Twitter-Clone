//
//  TweetService.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/21.
//

import Firebase

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping(DatabaseCompletion)) {
        // 현재 사용자 uid 가져오기
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 업로드할 구조
        let values = ["uid": uid,
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String : AnyObject]
        
        // uploadTweet할때 type에 따라 firebase에 업로드하는 데이터 내용이 달라짐.
        switch type {
        case .tweet:
            // childByAutoId -> 자동으로 id부여 후 딕셔너리구조로 넣기, 그리고 completion(완료후 나머진 거기서 직접설정해!)
            REF_TWEETS.childByAutoId().updateChildValues(values) { err, ref in
                guard let tweetID = ref.key else { return }
                // 트윗 업로드가 완료된후 그키를 이용해 사용자 트윗 구조를 업데이트한다.
                REF_USERS_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            // tweet-replies아래에 보고있는 tweet에대한 tweetID를추가하고 그 아래에 자동으로 id를붙여준후, 자신의 벨류값들을 업데이트해준다.
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId()
                .updateChildValues(values, withCompletionBlock: completion)
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
    
    // 트윗의 답장을 가져오는 함수
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        // tweet-replies아래에 tweet.tweetID 아래있는 것들을 관찰하고 그값들을 snapshot으로 넘겨준다.
        REF_TWEET_REPLIES.child(tweet.tweetID).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
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
    
    func likeTweet(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        // tweets안에 tweet.tweetID아래에있는 likes값을 setValue(바꿔)해준다.
        REF_TWEETS.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.didLike {
            // unlike tweet
        } else {
            // like tweet
            // user-likes아래에 사용자 uid아래에 tweet.tweetID를 추가하고
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID: 1]) { err, ref in
                // tweet-likes아래에 추가한 tweet.tweetID 아래에 uid 값을 추가해준다.
                REF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
}
