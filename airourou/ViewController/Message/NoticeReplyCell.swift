//
//  NoticeReplyCell.swift
//  爱肉肉
//
//  Created by isno on 16/3/14.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


class NoticeBaseCell:UITableViewCell {
    var data:JSON!
}

class NoticeReplyCell: NoticeBaseCell {
    
    override var data:JSON! {
        didSet {
            self.avatarView.ar_setImageWithURL(data["user"]["avatar_url"].string!)
            
            self.content.text = data["content"].string
            
            self.nickname.text = data["user"]["nickname"].string
            
            let title = NSMutableAttributedString()
            title.appendAttributedString(NSMutableAttributedString(string:data["title"].string!, attributes: [
                NSForegroundColorAttributeName:UIColor(rgba: "#aeaeae")
                ]))
            
            title.appendAttributedString(NSMutableAttributedString(string:data["topic_title"].string! ))
            self.title.attributedText = title

            
            self.signature.text = data["user"]["signature"].string
            self.createdAt.text = data["created_at"].string
        }
    }
    
    /** 帖子内容 */
    private var content:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font          = UIFont.systemFontOfSize(14)
        label.textColor     = UIColor(rgba: "#676767")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 用户资料
    private var avatarView:UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 36/2
        view.clipsToBounds = true
        return view
    }()
    /**
     用户昵称
     */
    private var nickname:UILabel = {
        let name = UILabel()
        name.textColor = UIColor(rgba: "#444")
        name.font = UIFont.systemFontOfSize(14)
        return name
    }()
    
    private var boxView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    private var topicBoxView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgba: "#f7f7f7")
        
        /*
        view.layer.borderColor = UIColor(rgba: "#edebeb").CGColor
        view.layer.borderWidth = 0.5
        */
        view.layer.cornerRadius = 3
        view.clipsToBounds = true

        
        return view
    }()
    
    private var title:UILabel = {
        let name = UILabel()
        name.textColor = UIColor(rgba: "#767676")
        name.font = UIFont.systemFontOfSize(14)
        return name
    }()
    
    // 话题创建时间
    var signature:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#adadad")
        label.font = UIFont.systemFontOfSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 帖子创建时间
    private var createdAt:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#adadad")
        label.font = UIFont.systemFontOfSize(13)
        return label
    }()
    
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.backgroundColor = UIConstant.AppBackgroundColor
        
        self.addSubview(boxView)
        boxView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.bottom.right.equalTo(0)
        }
        
        boxView.addSubview(createdAt)
        createdAt.snp_makeConstraints { (make) in
            make.right.equalTo(-16)
            make.top.equalTo(8)
        }
        
        boxView.addSubview(avatarView)
        avatarView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(8)
            make.width.equalTo(36)
            make.height.equalTo(36)
            make.top.equalTo(8)
        }
        
        self.boxView.addSubview(nickname)

        self.nickname.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.avatarView.snp_right).offset(8)
            make.top.equalTo(self.avatarView.snp_top).offset(0)
        }
        
        self.signature.translatesAutoresizingMaskIntoConstraints = false
        self.boxView.addSubview(self.signature)
        
        self.signature.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.nickname.snp_bottom).offset(2)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
        }

        
        
        self.boxView.addSubview(content)
        
        self.content.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(8)
            make.top.equalTo(self.avatarView.snp_bottom).offset(8)
            make.right.equalTo(self.boxView).offset(-8)
            
        }
        
        boxView.addSubview(topicBoxView)
        topicBoxView.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(content.snp_bottom).offset(8)

        }
        topicBoxView.addSubview(self.title)
        title.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        
        let line = UIView()
        line.backgroundColor = UIConstant.AppBackgroundColor
        boxView.addSubview(line)
        line.snp_makeConstraints { (make) in
            make.top.equalTo(topicBoxView.snp_bottom).offset(8)
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(0.5)
            make.bottom.equalTo(-8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
        
    }
}