//
//  ActionSheetLauncher.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/26.
//

import Foundation

class ActionSheetLauncher: NSObject {
    
    // MARK: - Properties

    // 내 트윗이면 삭제하고 다른 트윗이면 언팔로우할수있게 구분하기위해 user를 가져온다.
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init()
    }
    
    // MARK: - Helpers
    
    func show() {
        print("DEBUG: Show action sheet for user \(user.username)")
    }
}
