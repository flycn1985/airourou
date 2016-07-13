//
//  BbsCell.swift
//  爱肉肉
//
//  Created by isno on 16/1/25.
//  Copyright © 2016年 isno. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class BbsCell:UITableViewCell {
    
    private var boardImageView:UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        return view
    }()
    private var boarName:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(16.0)
        return label
    }()
    private var boardTip:Badge = {
        let badge = Badge()
        badge.textColor = UIColor.whiteColor()
        badge.font = UIFont.systemFontOfSize(12)
        return badge
    }()
    
    var model:JSON! {
        didSet {
            self.boarName.text = model!["name"].string!
            self.setBoardTip(model!["is_visited"].bool!, unreadNum: model!["unread_num"].int!)
            self.boardImageView.ar_setImageWithURL(model!["icon_url"].string!)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /**
     设置论坛badge
     
     @params bool 是否浏览
     @params int 最新帖子数量
     */
    func setBoardTip(isVisted:Bool, unreadNum:Int) {
        self.boardTip.hidden = false
        if isVisted == false {
            self.boardTip.text = "未浏览"
            self.boardTip.layer.backgroundColor = UIColor(rgba: "#cecccc").CGColor
        }  else {
            if unreadNum > 0 {
                self.boardTip.text = "\(unreadNum)"
            } else {
                self.boardTip.hidden = true
            }
            self.boardTip.layer.backgroundColor = UIColor(rgba: "#f90").CGColor
        }
    }
    
    /**
     setupViews
     */
    private func setupViews() {
        
        self.boardImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.boardImageView)
        
        
        self.boardImageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(5)
            make.left.equalTo(self.contentView).offset(15)
            make.size.equalTo(52)
        }
        
        self.boarName.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.boarName)
        
        self.boarName.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(16)
            make.left.equalTo(self.boardImageView.snp_right).offset(5)
        }
        
        self.boardTip.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.boardTip)
        
        self.boardTip.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.boarName)
            make.left.equalTo(self.boarName.snp_right).offset(5)
        }
    }
    
    
}
