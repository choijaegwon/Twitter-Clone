//
//  MainTabController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/17.
//

import UIKit

class MainTabController: UITabBarController {

    // MARK: - Properties
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        uiTabBarSetting()
        configtureViewControllers()
    }
    
    // MARK: - Heplers
    
    func configtureViewControllers() {
        // TabBar에 추가하기
        let feed = FeedController()
        feed.tabBarItem.image = UIImage(named: "home_unselected")
        
        let explore = ExploreController()
        explore.tabBarItem.image = UIImage(named: "search_unselected")
        
        let notifications = NotificationsController()
        notifications.tabBarItem.image = UIImage(named: "search_unselected")
        
        let conversations = ConversationsController()
        conversations.tabBarItem.image = UIImage(named: "search_unselected")
        
        viewControllers = [feed, explore, notifications, conversations]
    }
    
    func uiTabBarSetting() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
