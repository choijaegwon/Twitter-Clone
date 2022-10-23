//
//  ProfileHeaderViewModel.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/23.
//

import Foundation

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets = 0
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
}
