//
//  TopicKeyboardView.swift
//  airourou
//
//  Created by isno on 16/5/3.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation

import KMPlaceholderTextView

class KeyboardUser:UIView {
    var avatarView:UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 26/2
        view.clipsToBounds = true
        view.userInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var content:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(rgba: "#6767")
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor  = UIColor(rgba: "#fff")
        self.hidden = true
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func  setupViews() {
        self.addSubview(self.avatarView)
        
        self.avatarView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(26)
            make.left.equalTo(8)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        self.addSubview(self.content)
        self.content.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatarView.snp_right).offset(8)
            make.centerY.equalTo(avatarView)
            make.right.equalTo(-8)
        }
        
    }
}

/**
 话题回复框
 
 */
class TopicKeyboardView: UIView {
    
    var likeComplete:(()-> Void)?
    
    var button:UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("发送", forState: .Normal)
        button.setTitleColor(UIColor(rgba:"#666"), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16)
        button.layer.cornerRadius = 4
        button.layer.borderColor = UIColor(rgba:"#777").CGColor
        button.layer.borderWidth = 0.8
        
        return button
    }()
    
     var likeButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named:"icon_topic_like"), forState: .Normal)
        button.setImage(UIImage(named:"icon_topic_like_hl"), forState: .Selected)
        
        return button
    }()
    var field:KMPlaceholderTextView = {
        let view = KMPlaceholderTextView()
        view.backgroundColor = UIColor.whiteColor()
        view.scrollEnabled = true
        view.placeholder = "说点什么吧"
        view.font = UIFont.systemFontOfSize(14)
        view.textColor = UIColor(rgba: "#555")
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        
        view.layer.borderColor = UIColor(rgba:"#f0f0f0").CGColor
        view.layer.borderWidth = 1
        
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor  = UIColor(rgba: "#fff")
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let line = UIView()
        line.backgroundColor = UIColor(rgba: "#ddd")
        self.addSubview(line)
        line.snp_makeConstraints { (make) -> Void in
            make.top.right.left.equalTo(0)
            make.height.equalTo(0.8)
        }
        
        self.addSubview(likeButton)
        likeButton.addTarget(self, action: #selector(TopicKeyboardView.likeClicked(_:)), forControlEvents: .TouchUpInside)
        likeButton.snp_makeConstraints { (make) in
            make.left.equalTo(12)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 23, height: 23))
        }
        self.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-16)
            make.width.equalTo(60)
            make.centerY.equalTo(self)
        }
        
        self.addSubview(self.field)
        
        self.field.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(likeButton.snp_right).offset(12)
            make.top.equalTo(8)
            make.right.equalTo(button.snp_left).offset(-16)
            make.bottom.equalTo(-8)
        }
    }
    @objc private func likeClicked(btn:UIButton) {
        if AuthHelper.sharedInstance.isLogin() == false {
            return
        }
        btn.selected = !btn.selected
        self.likeComplete!()
        
    }
}