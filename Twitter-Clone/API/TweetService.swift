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
        var values = ["uid": uid,
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String : Any]
        
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
            values["replyingTo"] = tweet.user.username
            
            // tweet-replies아래에 보고있는 tweet에대한 tweetID를추가하고 그 아래에 자동으로 id를붙여준후, 자신의 벨류값들을 업데이트해준다.
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId().updateChildValues(values) { err, ref in
                // replyKey란? 위에서 자동으로 넣은값(childByAutoId)이다.
                guard let replyKey = ref.key else { return }
                // user-replies아래에 uid를 추가하고, 거기에 [tweet.tweetID: replyKey]를 추가해준다.
                REF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetID: replyKey], withCompletionBlock: completion)
            }
        }
    }
    
    // 트윗가져오기
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
  
        // 내가 팔로우한 트윗만 가져오는 코드
        REF_USERS_FOLLOWING.child(currentUid).observe(.childAdded) { snapshot in
            let followingUid = snapshot.key
            
            REF_USERS_TWEETS.child(followingUid).observe(.childAdded) { snapshot in
                let tweetID = snapshot.key
                
                self.fetchTweet(withTweetID: tweetID) { tweet in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
        // 내트윗을 가져오는 코드
        REF_USERS_TWEETS.child(currentUid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    // 특정 사용자에 대한 트윗가져오기
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USERS_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetID tweetID: String, completion: @escaping(Tweet) -> Void) {
        // tweetID 키를 가지고 tweets에 접근해서 그트윗의 정보를 가져온다.
        REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            // Tweet에 저장되어있는 uid불러오기
            guard let uid = dictionary["uid"] as? String else { return }
            
            // Tweet에서 유저 정보를 사용하기 위함
            UserSerivce.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var replies = [Tweet]()
        // user-replies아래에 uid에있는걸관찰할건데
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { snapshot in
            // key값은 tweet.tweetID이고
            let tweetKey = snapshot.key
            // value값은 그 트윗아이디 아래있는 답장트윗이다.
            guard let replykey = snapshot.value as? String else { return }
            
            // tweet-replies아래에 tweetKey아래 replykey아래에 있는걸 전부다 가져온다.
            REF_TWEET_REPLIES.child(tweetKey).child(replykey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                // Tweet에 저장되어있는 uid불러오기
                guard let uid = dictionary["uid"] as? String else { return }
                let replyID = snapshot.key
                
                // Tweet에서 유저 정보를 사용하기 위함
                UserSerivce.shared.fetchUser(uid: uid) { user in
                    let reply = Tweet(user: user, tweetID: replyID, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
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
    
    func fetchLikes(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        // user-likes아래 user.uid아래 있는
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            // tweetID 을 가지고 넘겨준다.
            let tweetID = snapshot.key
            // 그걸기준으로 트윗을 가져온후, tweets배열에 넣고 반환해준다.
            self.fetchTweet(withTweetID: tweetID) { likedTweet in
                var tweet = likedTweet
                tweet.didLike = true
                
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
            // user-likes아래에 사용자 uid아래에 tweet.tweetID를 제거하고
            REF_USER_LIKES.child(uid).child(tweet.tweetID).removeValue { err, ref in
                // tweet-likes아래에 tweet.tweetID아래에 싫어요한 사용자만 제거한다.
                REF_TWEET_LIKES.child(tweet.tweetID).child(uid).removeValue(completionBlock: completion)
            }
        } else {
            // like tweet
            // user-likes아래에 사용자 uid아래에 tweet.tweetID를 추가하고
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID: 1]) { err, ref in
                // tweet-likes아래에 추가한 tweet.tweetID 아래에 uid 값을 추가해준다.
                REF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    // UserService의 checkIfUserFollowed과 같은 방식이다.
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // user-likes아래에 내 uid를 찾아간후, 그아래 내가보고있는 tweet의tweetID 값을 찾는다
        REF_USER_LIKES.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
            // 그다음 그 snapshot값이 존재하면 true 존재하지않으면 false를 반환해준다.
            completion(snapshot.exists())
        }
    }
}
