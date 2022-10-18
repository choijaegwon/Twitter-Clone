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
        let nav1 = templatNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        let explore = ExploreController()
        let nav2 = templatNavigationController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        
        let notifications = NotificationsController()
        let nav3 = templatNavigationController(image: UIImage(named: "search_unselected"), rootViewController: notifications)
        
        let conversations = ConversationsController()
        let nav4 = templatNavigationController(image: UIImage(named: "search_unselected"), rootViewController: conversations)
        
        viewControllers = [nav1, nav2, nav3, nav4]
    }
    
    // navBar를 편하게 만들어주는 함수.
    func templatNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
        
        return nav
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
