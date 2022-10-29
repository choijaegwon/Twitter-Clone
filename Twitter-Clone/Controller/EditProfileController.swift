//
//  EditProfileController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/28.
//

import UIKit

class EditProfileController: UITableViewController {
    
    // MARK: - Properties
    
    private let user: User
    private lazy var headerView = EditProfileHeader(user: user)
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTabelView()
    }
    
    // MARK: - Selectors
    
    @objc func handleCandle() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - API
    
    // MARK: - Helpers
    
    func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "Edit Profile"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCandle))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func configureTabelView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        tableView.tableFooterView = UIView()
        
        headerView.delegate = self
    }
}

extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        print("DEBUG: Handle change photo..")
    }
}
