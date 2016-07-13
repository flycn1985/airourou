//
//  FreeNoticeView.swift
//  爱肉肉
//
//  Created by isno on 16/3/1.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation

class FreeNoticeView:UIView {
    
    let tip1:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "交换分享帖浏览前必读"
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = UIColor(rgba: "#676767")
        return label
    }()
    
    let tip2:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1、分享版块贴子均由网友发表，本平台只提供信息展示，网友请仔细与分享者沟通具体细节，本平台不承担分享过程中出现的问题。"
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor(rgba: "#676767")
        return label
    }()
    
    let tip3:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2、提醒想获得分享的肉友们，尽量不要直接付款，请走淘宝链接或者担保交易，提高安全意识，否则有可能钱肉两空。"
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor(rgba: "#676767")
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupViews() {
        self.backgroundColor = UIConstant.AppBackgroundColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        
        self.addSubview(tip1)
        tip1.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(8)
            make.top.equalTo(8)
        }
        
        self.addSubview(tip2)
        tip2.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(8)
            make.top.equalTo(tip1.snp_bottom).offset(8)
            make.right.equalTo(-8)
        }
        
        self.addSubview(tip3)
        tip3.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(8)
            make.top.equalTo(tip2.snp_bottom).offset(8)
            make.right.equalTo(-8)
        }
        
    }
}