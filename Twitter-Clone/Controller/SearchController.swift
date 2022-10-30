//
//  ExploreController.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/18.
//

import UIKit

private let reuseIdentifier = "UserCell"

enum SearchControllerConfiguration {
    case messages
    case userSearch
}

class SearchController: UITableViewController {
    
    // MARK: - Properties
    
    private let config: SearchControllerConfiguration
    
    private var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // 검색창에서 글자가 추가되거나 삭제될때마다 테이블뷰가 리로드 된다
    private var filteredUsers = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // 검색모드에 있는지 없는지 확인해주는 함수
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    
    func fetchUsers() {
        UserSerivce.shared.fetchUser { users in
            self.users = users
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Heplers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = config == .messages ? "New Message" : "Explore"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        // tablecell의 높이
        tableView.rowHeight = 60
        // 검은줄 사라지게하기.
        tableView.separatorStyle = .none
        
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissal))
        }
    }
    
    // 서치바 만들어주기.
    func configureSearchController() {
        // SearchBar에 Text가 업데이트 될 때 마다 불리는 메소드
        searchController.searchResultsUpdater = self
        // 검색창을 눌렀을때, 배경이 false면 흰색 ture면 회색이 된다.
        searchController.obscuresBackgroundDuringPresentation = false
        // searchController가 검색하는 동안 네비게이션에 가려지지 않도록 한다.
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        // false면 최상위 뷰컨트롤러의 뷰까지 올라온다.
        definesPresentationContext = false
    }
}

// MARK: - UITableViewDelegate/DataSource

extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 검색하는 도중이면 필터링된 사용자수대로 나오고 그게아니면 users사용자수대로 나온다.
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        // 검색모드면 필터링된 유저를 그게아니라면 모든 유저를 표시
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        return cell
    }
    
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 검색모드와 아닌 모드에서 index가 꼬일 수 있기 때문에 그대로 가져와야한다.
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UISearchResultsUpdateing

extension SearchController: UISearchResultsUpdating {
    // 텍스트가 입력될 때마다 searchController.searchBar.text 글자를 받아온다.
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
    
        // users배열에서 searchText가 담고있는 username을 가져온다.
        filteredUsers = users.filter({ $0.username.localizedCaseInsensitiveContains(searchText) || $0.fullname.localizedCaseInsensitiveContains(searchText)
        })
    }
}
