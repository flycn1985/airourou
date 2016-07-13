//
//  MessageHead.swift
//  爱肉肉
//
//  Created by isno on 16/3/11.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation

class MessageHeadView:UIView {
    
    
    
    var replyBadge:Badge = {
        let badge = Badge()
        badge.textColor = UIColor.whiteColor()
        badge.font = UIFont.systemFontOfSize(12)
        badge.hidden = true
        return badge
    }()
    
    var systemBadge:Badge = {
        let badge = Badge()
        badge.textColor = UIColor.whiteColor()
        badge.font = UIFont.systemFontOfSize(12)
        badge.hidden = true
        return badge
    }()
    
    var likeBadge:Badge = {
        let badge = Badge()
        badge.textColor = UIColor.whiteColor()
        badge.font = UIFont.systemFontOfSize(12)
        badge.hidden = true
        return badge
    }()
    
    var replyBox:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var reply:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor(rgba: "#333")
        label.text = "回复"
        return label
    }()
    
    var system:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor(rgba: "#333")
        label.text = "系统通知"
        return label
    }()
    
    var like:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor(rgba: "#333")
        label.text = "喜欢"
        return label
    }()
    
    
    var systemBox:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var likeBox:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var SystemComplete:(() -> Void)?
    var ReplyComplete:(() -> Void)?
    var LikeComplete:(() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        backgroundColor = UIConstant.AppBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        setupSystem()
        setupLike()
        setupReply()
        
    }
    func setupSystem() {
        self.addSubview(systemBox)
        systemBox.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
        systemBox.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(MessageHeadView.systemClicked))
        systemBox.addGestureRecognizer(tap)
 
        let view  = UIImageView(image: UIImage(named: "icon_message_system"))
        view.translatesAutoresizingMaskIntoConstraints = false
        systemBox.addSubview(view)
        view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(12)
            make.centerY.equalTo(systemBox)
        }
        
        systemBox.addSubview(self.system)
        system.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_right).offset(8)
            make.top.equalTo(view.snp_top).offset(2)
        }
        systemBox.addSubview(self.systemBadge)
        systemBadge.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(system.snp_right).offset(3)
            make.centerY.equalTo(system)
        }
    }
    func systemClicked() {
        SystemComplete!()
    }
    func replyClicked() {
        ReplyComplete!()
    }
    func likeClicked() {
        LikeComplete!()
    }
    func setupLike() {
        self.addSubview(likeBox)
        likeBox.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(systemBox.snp_bottom).offset(0.5)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
        
        likeBox.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(MessageHeadView.likeClicked))
        likeBox.addGestureRecognizer(tap)
        
        
        let view  = UIImageView(image: UIImage(named: "icon_message_like"))
        view.translatesAutoresizingMaskIntoConstraints = false
        likeBox.addSubview(view)
        view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(12)
            make.centerY.equalTo(likeBox)
        }
        
        likeBox.addSubview(self.like)
        like.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_right).offset(8)
            make.top.equalTo(view.snp_top).offset(0)
        }
        
        likeBox.addSubview(self.likeBadge)
        likeBadge.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(like.snp_right).offset(3)
            make.centerY.equalTo(like)
        }
        
    }
    func setupReply() {
        self.addSubview(replyBox)
        replyBox.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(likeBox.snp_bottom).offset(0.5)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
        
        replyBox.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(MessageHeadView.replyClicked))
        replyBox.addGestureRecognizer(tap)

        
        
        let view  = UIImageView(image: UIImage(named: "icon_message_reply"))
        view.translatesAutoresizingMaskIntoConstraints = false
        replyBox.addSubview(view)
        view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(12)
            make.centerY.equalTo(replyBox)
        }
        
        replyBox.addSubview(self.reply)
        reply.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_right).offset(8)
            make.top.equalTo(view.snp_top).offset(2)
        }
        
        replyBox.addSubview(self.replyBadge)
        replyBadge.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(reply.snp_right).offset(3)
            make.centerY.equalTo(reply)
        }
        
    }
    
    
}