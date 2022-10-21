//
//  FeedController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/18.
//

import UIKit

class FeedController: UIViewController {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            print("DEBUG: Did set user in feed controller..")
        }
    }
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Heplers
    
    func configureUI() {
        view.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        // navBar왼쪽에 띄울 UIImageView() 만들기
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .twitterBlue
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        // navBar왼쪽에 넣기.
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}
