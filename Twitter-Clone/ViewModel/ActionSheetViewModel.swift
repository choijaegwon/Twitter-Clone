//
//  ActionSheetViewModel.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/26.
//

import Foundation

enum ActionSheetOptions {
    case follow(User)
    case unfollow(User)
    case report
    case delete
    
    var description: String {
        switch self {
        case .follow(let user):
            return "Follow @\(user.username)"
        case .unfollow(let user):
            return "Unfollow @\(user.username)"
        case .report:
            return "Report Tweet"
        case .delete:
            return "Delete Tweet"
        }
    }
}

struct ActionSheetViewModel {
    
    private let user: User
    
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        // 보고있는 트윗이 내트윗일경우 삭제옵션 추가
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            // 사용자가 현재 팔로우를하고있으면 언팔로우하고, 안하고있으면 팔로우 옵션추가
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        
        results.append(.report)
        
        return results
    }
    
    init(user: User) {
        self.user = user
    }
}


