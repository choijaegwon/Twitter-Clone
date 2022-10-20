//
//  MainTabController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/17.
//

import UIKit
import Firebase

class MainTabController: UITabBarController {

    // MARK: - Properties
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        logUserOut()
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    
    // 로그인 되어있을때, 안되어있을때 화면 구분하기
    func authenticateUserAndConfigureUI() {
        // 로그인이 안되어있으면, 로그인화면 보여주기
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            uiTabBarSetting()
            configtureViewControllers()
            configureUI()
        }
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Did log user out..")
        } catch let error {
            print("DEBUG: Failed to sign out wuth error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Selectors
    
    @objc func actionButtonTapped() {
        print(#function)
    }

    
    // MARK: - Heplers
    func configureUI() {
        view.addSubview(actionButton)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
    }
    
    func configtureViewControllers() {
        // TabBar에 추가하기
        let feed = FeedController()
        let nav1 = templatNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        let explore = ExploreController()
        let nav2 = templatNavigationController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        
        let notifications = NotificationsController()
        let nav3 = templatNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notifications)
        
        let conversations = ConversationsController()
        let nav4 = templatNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: conversations)
        
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
        nav.navigationBar.scrollEdgeAppearance = appearance
        
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
