//
//  UploadTweetViewModel.swift
//  Twitter-Clone
//
//  Created by Jae kwon Choi on 2022/10/25.
//

import UIKit

enum UploadTweetConfiguartion {
    case tweet
    // 답장으로하면 항상 다른 트윗으로 연결됨
    case reply(Tweet)
}

struct UploadTweetViewModel {
    
    // 업로드일경우엔 Tweet을 보여주고 답장일경우엔 Relpy를 보여준다.
    let actionButtonTitle: String
    // 업로드인경우와, 답장트윗의 경우 에 따라 placeholder의 내용이 달라진다.
    let placeholderText: String
    var shouldShowReplyLabel: Bool
    // 회신하는 텍스트
    var replyText: String?
    
    init(config: UploadTweetConfiguartion) {
        switch config {
        case .tweet:
            actionButtonTitle = "Tweet"
            placeholderText = "What's happening?"
            shouldShowReplyLabel = false
        case .reply(let tweet):
            actionButtonTitle = "Reply"
            placeholderText = "Tweet your reply"
            shouldShowReplyLabel = true
            replyText = "Replying to @\(tweet.user.username)"
        }
    }
}
