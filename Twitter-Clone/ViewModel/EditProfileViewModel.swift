//
//  EditProfileViewModel.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/29.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Name"
        case .bio: return "Bio"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        case .fullname:
            return user.fullname
        case .username:
            return user.username
        case .bio:
            return user.bio
        }
    }
    
    // option이 .bio와 같으면 TextFiled를 숨기고 TextView를 표시하고
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    // option이 .bio와 다르면 TextView를 숨기고 TextField를 표시한다.
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
