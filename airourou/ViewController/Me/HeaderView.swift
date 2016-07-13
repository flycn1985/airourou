//
//  HeaderView.swift
//  爱肉肉
//
//  Created by isno on 16/2/14.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class UserHeadView:UIView {
    
    var nickname:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFontOfSize(32)
        label.textColor = UIColor.whiteColor()
        label.text = " "
        label.shadowColor=UIColor(rgba: "#666")
        label.shadowOffset=CGSizeMake(1, 1)
        return label
    }()
    var avatarView:UIImageView = {
        let view = UIImageView(image: UIImage(named: "defaultAvatar"))
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        view.contentMode = .ScaleAspectFill
        view.layer.cornerRadius = 82/2
        return view
    }()
    
    // 肉票
    var money:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFontOfSize(18)
        label.text = " "
        label.textColor = UIColor(rgba: "#f4c600")
        label.shadowColor=UIColor(rgba: "#666")
        label.shadowOffset=CGSizeMake(1, 1)
        return label
    }()
    
    var location:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFontOfSize(12)
        label.text = " "
        label.textColor = UIColor(rgba: "#fff")
        label.shadowColor=UIColor(rgba: "#666")
        label.shadowOffset=CGSizeMake(1, 1)
        return label
    }()
    
    var followButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("关注", forState: .Normal)
        button.setTitle("已关注", forState: .Selected)
        button.setTitleColor(UIColor(rgba: "#676767"), forState: .Normal)
        button.setTitleColor(UIColor(rgba: "#676767"), forState: .Selected)
        button.titleLabel!.font = UIFont.systemFontOfSize(16)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -1)
        button.setImage(UIImage(named: "icon_follow"), forState: .Normal)
        button.setImage(UIImage(named: "icon_follow_hl"), forState: .Selected)
       
        return button
    }()
    
    var chatButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("聊天", forState: .Normal)
        button.setTitleColor(UIColor(rgba: "#676767"), forState: .Normal)
        button.titleLabel!.font = UIFont.systemFontOfSize(16)
        
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -1)
        
        button.setImage(UIImage(named: "icon_chat"), forState: .Normal)
        
        return button
    }()
    var levelIconView:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    var followCallback:(() -> Void)?
    var chatCallback:(() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func  setupViews() {
        /** 昵称 */
        self.addSubview(self.nickname)
        self.nickname.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(62)
            make.centerX.equalTo(self)
        }
        
        /** 肉币 */
        self.addSubview(self.money)
        self.money.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.nickname.snp_bottom).offset(21)
            make.centerX.equalTo(self.snp_centerX)
        }
        
        /** 头像 */
        self.addSubview(avatarView)
        self.avatarView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(82)
            make.top.equalTo(money.snp_bottom).offset(21)
            make.centerX.equalTo(self)
        }
        
        self.addSubview(levelIconView)
        levelIconView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.avatarView.snp_bottom).offset(-5)
            make.right.equalTo(self.avatarView.snp_right).offset(0)
            make.height.equalTo(10)
            make.width.equalTo(16)
        }
        
        /* 位置 */
        self.addSubview(self.location)
        self.location.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.avatarView.snp_bottom).offset(18)
            make.centerX.equalTo(self)
        }
        
        let opView = UIView()
        opView.backgroundColor = UIColor.whiteColor()
        opView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(opView)
        opView.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(0)
            make.height.equalTo(42)
            make.bottom.equalTo(0)
        }
        opView.addSubview(followButton)
        followButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(self.snp_centerX).offset(-21)
            make.width.equalTo(90)
            make.centerY.equalTo(opView)
        }
        
        
        opView.addSubview(chatButton)
        
        chatButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.snp_centerX).offset(21)
            make.width.equalTo(90)
            make.centerY.equalTo(opView)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(rgba: "#e3e4e5")
        line.translatesAutoresizingMaskIntoConstraints = false
        opView.addSubview(line)
        
        line.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(0.5)
            make.centerX.equalTo(opView)
        }
        
    
        let view = UIView()
        view.backgroundColor = UIColor(rgba: "#e3e4e5")
        view.translatesAutoresizingMaskIntoConstraints = false
       
        self.addSubview(view)
        
        view.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(0)
            make.height.equalTo(1)
            make.left.right.equalTo(0)
        }
    }
}