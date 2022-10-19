//
//  ConversationsController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/18.
//

import UIKit

class ConversationsController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Heplers
 
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Messages"
    }
}
