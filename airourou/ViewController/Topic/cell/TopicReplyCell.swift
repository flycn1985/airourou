//
//  TopicReplyCell.swift
//  爱肉肉
//
//  Created by isno on 16/3/7.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import UIKit

class TopicReplyCell:UITableViewCell {
    
    var replyComplete:((replyId:Int) -> Void)?
    
    private var nav:UIViewController?
    private var data:JSON?
    // 等级
    var levelIconView:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var replyBox:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgba: "#f6f6f6")
        return view
    }()

    
    private var avatarView:UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 28/2
        view.clipsToBounds = true
        view.userInteractionEnabled = true
        return view
    }()
    
    private var nickname:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#656565")
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()
    private var createdAt:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#bdbdbd")
        label.font = UIFont.systemFontOfSize(12)
        return label
    }()
    private var content:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor(rgba: "#4f4f4f")
        
        return label
    }()
    
    private var bottomLine:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgba: "#e4e4e4")
        return view
    }()
    
    var bestIconView:UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_ask_best"))
        return view
    }()
    
    var replyButton:UIButton = {
        
        let button = UIButton(type: .Custom)
        button.setTitle("回复", forState: .Normal)
        button.setTitleColor(UIColor(rgba: "#3f7091"), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        
        self.setupViews()
    }
    required init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has nont been implemented")
    }
    
    func bind(data:JSON, nav:UIViewController) {
        self.nav = nav
        self.data = data
        
        self.avatarView.sd_setImageWithURL(NSURL(string: data["user"]["avatar_url"].string!))
        self.nickname.text = data["user"]["nickname"].string!
        self.createdAt.text = data["created_at"].string!
        if data["is_best"].int == 1 {
            bestIconView.hidden = false
        } else {
            bestIconView.hidden = true
        }
        if data["user"]["level"].int > 0 {
            self.levelIconView.image = UIImage(named: "level\(data["user"]["level"].int!).png")
            
        }
        self.content.text = data["content"].string
    }
    
    private func setupViews() {
        
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TopicReplyCell.avatarPressed)))
        self.contentView.addSubview(self.avatarView)
        
        self.avatarView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(28)
            make.left.equalTo(8)
            make.top.equalTo(8)
        }
        self.contentView.addSubview(self.levelIconView)
        levelIconView.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.width.equalTo(16)
            make.right.equalTo(self.avatarView.snp_right).offset(3)
            make.bottom.equalTo(self.avatarView.snp_bottom).offset(-3)
        }
        
        self.contentView.addSubview(bestIconView)
        bestIconView.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(0)
            make.top.equalTo(0)
        }
        
        self.contentView.addSubview(self.nickname)
        self.nickname.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.avatarView.snp_top).offset(0)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
        }
        
        self.contentView.addSubview(self.content)
        
        self.contentView.addSubview(replyButton)
        replyButton.snp_makeConstraints { (make) in
            make.right.equalTo(-16)
            make.top.equalTo(8)
        }
        replyButton.addTarget(self, action: #selector(TopicReplyCell.replyClicked), forControlEvents:.TouchUpInside)
        
        self.content.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.nickname.snp_bottom).offset(8)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
            make.right.equalTo(self.contentView).offset(-8)
        }
        
        self.contentView.addSubview(self.replyBox)
        replyBox.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.content.snp_bottom).offset(8)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
            make.right.equalTo(self.contentView).offset(-8)
        }
        
        self.contentView.addSubview(self.createdAt)
        
        self.createdAt.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.replyBox.snp_bottom).offset(8)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
        }
        
        self.contentView.addSubview(self.bottomLine)
        
        self.bottomLine.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.createdAt.snp_bottom).offset(8)
            make.height.equalTo(0.5)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
            make.right.equalTo(-8)
            make.bottom.equalTo(0)
        }
    }
    func replyClicked() {
        self.replyComplete!(replyId:data!["_id"].int!)
    }
    
    func avatarPressed() {
       let vc = UserPageViewController()
        vc.UserId = data!["user"]["_id"].int!
        self.nav?.navigationController?.pushViewController(vc, animated: true)
    }
    
}