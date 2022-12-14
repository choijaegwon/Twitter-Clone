//
//  TweetController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/24.
//

import UIKit

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "TweetHeader"

class TweetController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var tweet: Tweet
    // ActionSheetLauncher안에 show메서드를 사용하기 위한 변수
    private var actionSheetLauncher: ActionSheetLauncher!
    // 답글이 담길때마다 화면을 리로드해준다.
    private var replies = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
     
    // MARK: - Lifecycle
    
    // Feed에서 받아올 수 있게 init으로 생성
    init(tweet: Tweet) {
        // Feed에서 받아온 tweet을 TweetController에있는 tweet에 넣어주기
        self.tweet = tweet
        // tweet을 받아오기위해서 UICollectionViewFlowLayout()을 넣어준다.
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchReplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
        TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
            self.tweet.didLike = didLike
        }
    }
    
    // MARK: - API
    
    func fetchReplies() {
        print("DEBUG: Tweet ID is \(tweet.tweetID)")
        TweetService.shared.fetchReplies(forTweet: tweet) { replies in
            self.replies = replies
        }
    }

    // MARK: - Helpers

    func configureCollectionView() {
        collectionView.backgroundColor = .white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    fileprivate func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
}

// MARK: - UICollectionViewDataSoure

extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        // cell의 tweet은 replies에서 가져오는데 indexPath.row순서대로 가져온다.
        cell.tweet = replies[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TweetController {
    // TweetHeader를 사용하기위한 메서드
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! TweetHeader
        header.tweet = tweet
        header.delegate = self
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TweetController: UICollectionViewDelegateFlowLayout {
    // 헤더의 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweet)
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: captionHeight + 260)
    }
    
    // cell의 사이즈 조절
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

// MARK: - TweetHeaderDelegate

extension TweetController: TweetHeaderDelegate {
    func showProfileUser() {
        let controller = ProfileController(user: tweet.user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleFetchUser(withUsername username: String) {
        UserSerivce.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showActionSheet() {
        // 내트윗이면
        if tweet.user.isCurrentUser {
            showActionSheet(forUser: tweet.user)
        } else {
            // 팔로우했는지 안해는지확인하고, 그정보를 ActionSheetLauncher에 넘겨준다.
            UserSerivce.shared.checkIfUserFollowed(uid: tweet.user.uid) { isFollowed in
                var user = self.tweet.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
    }
}

// MARK: - ActionSheetLauncherDelegate

extension TweetController: ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserSerivce.shared.followUser(uid: user.uid) { err, ref in
                print("DEBUG: Did follow user \(user.username)")
            }
        case .unfollow(let user):
            UserSerivce.shared.unfollowUser(uid: user.uid) { err, ref in
                print("DEBUG: Did unfollow user \(user.username)")
            }
        case .report:
            print("DEBUG: Repot tweet")
        case .delete:
            print("DEBUG: Delete tweet..")
        }
    }
}
