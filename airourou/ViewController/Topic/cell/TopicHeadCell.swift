//
//  TopicHeadCell.swift
//  爱肉肉
//
//  Created by isno on 16/3/3.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import SwiftyJSON
import WebKit

class TopicBaseCell: UITableViewCell {
    
    var data:JSON!
    var UserComplete:(() -> Void)?
    
    var HtmlComplete:((webView:WKWebView) -> Void)?
    
    var HtmlAlertComplete:((view:UIAlertController) -> Void)?

    var ShowShareUsersComplete:((topicId:Int) -> Void)?
    
    var ShowImagesComplete:((currentIndex:Int) -> Void)?

    var replyTo:JSON!
}

class TopicHeadCell:UITableViewCell{
    
    private var nav:UINavigationController?
    private var data:JSON?
    
    // 主题内容
    private var title:UILabel = {
        let label = UILabel()
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.textColor = UIColor(rgba: "#444")
        label.font = UIFont.boldSystemFontOfSize(18)
        return label
    }()
    
    // 头像
    private var avatarView:UIImageView = {
        let view = UIImageView()
        view.userInteractionEnabled  = true
        view.clipsToBounds = true
        view.layer.cornerRadius = 42/2
        return view
    }()
    
    // 用户昵称
    private var nickname:UILabel = {
        let label = UILabel()
        label.userInteractionEnabled = true
        label.textColor = UIColor(rgba: "#3a3a3a")
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()
    // 话题创建时间
    var createdAt:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#bdbdbd")
        label.font = UIFont.systemFontOfSize(13)
        return label
    }()
    
    
    private var platform:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#bdbdbd")
        label.font = UIFont.systemFontOfSize(13)
        return label
    }()
    
    // 等级
    var levelIconView:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    // 管理员
    private var isAdmin:UILabel = {
        let name = UILabel()
        name.textColor = UIColor.whiteColor()
        name.font = UIFont.systemFontOfSize(11)
        name.backgroundColor = UIColor(rgba: "#f90")
        name.text = "管理员"
        name.layer.cornerRadius = 5
        name.clipsToBounds = true
        name.textAlignment = .Center
        name.hidden = true
        return name
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIColor.whiteColor()
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.contentView.addSubview(title)
        title.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(8)
            make.left.equalTo(8)
            make.right.equalTo(-8)
        }
        
        /** 头像 */
        self.contentView.addSubview(avatarView)
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TopicHeadCell.avatarPressed)))
        
        avatarView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(title.snp_bottom).offset(12)
            make.size.equalTo(42)
            make.left.equalTo(8)
            make.bottom.equalTo(-8)
        }
        
        self.contentView.addSubview(self.levelIconView)
        levelIconView.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.width.equalTo(16)
            make.right.equalTo(self.avatarView.snp_right).offset(3)
            make.bottom.equalTo(self.avatarView.snp_bottom).offset(-3)
        }
        
        
        /** nickname */
        self.contentView.addSubview(self.nickname)
        self.nickname.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.avatarView.snp_top).offset(3)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
        }
        self.nickname.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TopicHeadCell.avatarPressed)))

        
        self.contentView.addSubview(isAdmin)
        self.isAdmin.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.nickname.snp_right).offset(8)
            make.width.equalTo(48)
            make.height.equalTo(15)
            make.centerY.equalTo(self.nickname.snp_centerY)
        }
        
        /** 帖子创建时间 */
        self.contentView.addSubview(self.createdAt)
        
        self.createdAt.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.nickname.snp_baseline).offset(5)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
        }
        
        self.contentView.addSubview(self.platform)
        self.platform.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(createdAt)
            make.left.equalTo(self.createdAt.snp_right).offset(3)
        }
    }
    
    func bind(data:JSON, nav:UINavigationController) {
        self.data = data
        self.nav = nav
        
        self.title.text = data["title"].string
        self.avatarView.ar_setImageWithURL(data["user"]["avatar_url"].string!)
        self.nickname.text = data["user"]["nickname"].string
        self.createdAt.text = data["created_at"].string
        self.platform.text = data["platform"].string
        
        if data["user"]["level"].int > 0 {
            self.levelIconView.image = UIImage(named: "level\(data["user"]["level"].int!).png")
            
        }
        if data["user"]["is_show_admin"].bool == true {
            self.isAdmin.hidden = false
        } else {
            self.isAdmin.hidden = true
        }
    }
    
    func avatarPressed() {
        let vc = UserPageViewController()
        vc.UserId = data!["user"]["_id"].int!
        self.nav!.pushViewController(vc, animated: true)
        
    }
}