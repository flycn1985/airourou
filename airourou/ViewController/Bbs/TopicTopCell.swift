//
//  TopicTopCell.swift
//  爱肉肉
//
//  Created by isno on 16/2/22.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit


import UIKit
import SwiftyJSON

class TopicTopCell:UITableViewCell {
    private var topicTitle  = UILabel()
    private var boxView = UIView()
    
    internal var model:JSON! {
        didSet {
            self.topicTitle.text = model["title"].string!
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIConstant.AppBackgroundColor
        
        self.setupViews()
    }
    required init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has nont been implemented")
    }
    func setupViews() {
        
        self.boxView.backgroundColor = UIColor.whiteColor()
        self.boxView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.boxView)
        
        self.boxView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(0)
            make.left.right.equalTo(0)
            make.bottom.equalTo(-0.5)
        }
        
        let icon = UIImageView(image: UIImage(named: "icon_top"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        self.boxView.addSubview(icon)
        icon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.boxView)
            make.left.equalTo(5)
        }
        
        self.topicTitle.font = UIFont.boldSystemFontOfSize(16)
        self.topicTitle.textColor = UIColor(rgba: "#555")
        
        self.topicTitle.translatesAutoresizingMaskIntoConstraints = false
        self.boxView.addSubview(self.topicTitle)
        
        self.topicTitle.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.left.equalTo(icon.snp_right).offset(5)
        }
    }
}