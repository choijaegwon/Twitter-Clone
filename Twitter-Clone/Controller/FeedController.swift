//
//  FeedController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/18.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var tweets = [Tweet]() {
        // 정보를 받아올때, 다시 리로드해준다.(그이유는 처음에 그냥 깔면 data가 없는 상태로 로드되기 때문)
        didSet {
            collectionView.reloadData()
        }
    }
    
    var user: User? {
        didSet {
            configureLeftBarButton()
        }
    }
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    
    func fetchTweets() {
        TweetService.shared.fetchTweets { tweets in
            // 넘어온 정보를 [tweets]배열에 넘겨주기
            self.tweets = tweets
            // 사용자가 그 tweet을 좋아하는지 안하는지 확인하는 메서드
            self.checkIfUserLikedTweets(tweets)
        }
    }
    
    func checkIfUserLikedTweets(_ tweets: [Tweet]) {
        // index번호를 얻고 그 얻은 index번호를 이용해서
        for (index, tweet) in tweets.enumerated() {
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                // didLike자체가 false이기때문에 좋아요가 눌렸으면 그냥 넘어가고 안눌렸으면 아래로 넘어가기,
                guard didLike == true else { return }
                // 여기에서 index번째 tweet의 didLike을 true로 바꿔주기.
                self.tweets[index].didLike = true
            }
        }
    }
    
    // MARK: - Heplers
    
    func configureUI() {
        view.backgroundColor = .white
        
        // cell등록하기
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        // navBar왼쪽에 띄울 UIImageView() 만들기
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        // SDWebImage라이브러리를 사용해서 이미지 세팅해주기
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        // navBar왼쪽에 넣기.
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}

// MARK: - UICollectionViewDelegate/DataSource

extension FeedController {
    
    //섹션의 항목 수
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    // 어떤 cell을 보여줄건지
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        // 각셀의 순서에 맞게 TweetCell에 있는 tweet에 넣어준다.(여기서 TweetCell에있는 tweet에 didSet에 실행됨)
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Feed에 있는 tweet을 indexPath.row을 통해 몇번째 tweet이 클릭되었는지 확인후, 그걸 넘겨준다.
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    
    // cell의 사이즈 조절
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 선택한 cell을 넘겨주도록한다.
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: height + 72)
    }
}

// MARK: - TweetCellDelegate

extension FeedController: TweetCellDelegate {
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.likeTweet(tweet: tweet) { err, ref in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
        }
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

