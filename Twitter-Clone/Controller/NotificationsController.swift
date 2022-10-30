//
//  NotificationsController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/18.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    // MARK: - Properties

    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Selectors

    @objc func handleRefresh() {
        // 새로고침할때마다 Notifications 가져오기
        fetchNotifications()
    }
    
    // MARK: - API
    
    func fetchNotifications() {
        // 가져온후 새로고침 끝내기
        refreshControl?.endRefreshing()
        
        NotificationService.shared.fetchNotification { notifications in
            // 알람 순서 정렬하기
            self.notifications = notifications.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserIsFollowed(notifications: notifications)
            self.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserIsFollowed(notifications: [Notification]) {
        guard !notifications.isEmpty else { return }
        
        notifications.forEach { notification in
            
            // 해당 사용자를 팔로우하는지 확인한다.
            guard case .follow = notification.type else { return }
            // 사용자가 해당 사용자에게 동일한 알람을 보내도록하기
            let user = notification.user
        
            // 팔로우가 되어있는지 확인
            UserSerivce.shared.checkIfUserFollowed(uid: user.uid) { isFollowd in
                
                // 트윗으로 이동하여 좋아요 누른 트윗을 찾은다음 tweets으로가서 업데이트한다.
                if let index = self.notifications.firstIndex(where: { $0.user.uid == notification.user.uid }) {
                    // 팔로우상태를 넣어주기
                    self.notifications[index].user.isFollowed = isFollowd
                }
            }
        }
    }

    
    // MARK: - Heplers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        // 아래로 스와이프하면 새로고침
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
}

// MARK: - UITableViewDataSource

extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 알람 정보 가져오기
        let notification = notifications[indexPath.row]
        guard let tweetID = notification.tweetID else { return }
        
        // 트윗알람을 누르면 그트윗으로 이동하기.
        TweetService.shared.fetchTweet(withTweetID: tweetID) { tweet in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - NotificationCellDelegate

extension NotificationsController: NotificationCellDelegate {
    func didTapFollow(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        // user.isFollowed는 현재상태를 가져옴 true면 언팔로우하기, false면 팔로우하기
        if user.isFollowed {
            UserSerivce.shared.unfollowUser(uid: user.uid) { err, ref in
                // cell의 UI 바꿔주기
                cell.notification?.user.isFollowed = false
            }
        } else {
            UserSerivce.shared.followUser(uid: user.uid) { err, ref in
                // cell의 UI 바꿔주기
                cell.notification?.user.isFollowed = true
            }
        }
    }
    
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
