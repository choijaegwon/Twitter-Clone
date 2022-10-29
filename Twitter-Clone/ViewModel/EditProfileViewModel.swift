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
