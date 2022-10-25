//
//  ActionSheetLauncher.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/26.
//

import UIKit

private let reuseIdentifier = "ActionSheetCell"

class ActionSheetLauncher: NSObject {
    
    // MARK: - Properties

    // 내 트윗이면 삭제하고 다른 트윗이면 언팔로우할수있게 구분하기위해 user를 가져온다.
    private let user: User
    private let tableView = UITableView()
    private var window: UIWindow?
    // 뒷 배경 흐리게하기
    private lazy var blackView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    // MARK: - Lifecycle

    init(user: User) {
        self.user = user
        super.init()
        
        configureTabelView()
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += 300
        }
    }
    
    // MARK: - Helpers
    
    func show() {
        print("DEBUG: Show action sheet for user \(user.username)")
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) else { return }
        self.window = window
        
        // 뒤에 흐린 검은색배경하기
        window.addSubview(blackView)
        blackView.frame = window.frame
        
        window.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 300)
        
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            // 0.5초동안 300으로 높이를 300으로 올리기(애니메이션 효과를 주기위함)
            self.tableView.frame.origin.y -= 300
        }
    }
    
    func configureTabelView() {
        tableView.backgroundColor = .red
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
}

extension ActionSheetLauncher: UITableViewDelegate {

}
