//
//  TopicReplyToCell.swift
//  爱肉肉
//
//  Created by isno on 16/3/10.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

import SwiftyJSON


class TopicReplyToCell:TopicReplyCell {
    
    override func bind(data:JSON, nav:UIViewController) {
        super.bind(data, nav:nav)
        let text = NSMutableAttributedString()
        
        text.appendAttributedString(NSMutableAttributedString(string:data["reply_to"]["nickname"].string! + ": ", attributes: [
            NSForegroundColorAttributeName : UIConstant.FontLightColor]))
        
        text.appendAttributedString(NSMutableAttributedString(string:data["reply_to"]["content"].string!))
        replyContent.attributedText = text
        
    }
    
    var replyContent:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#555")
        label.font = UIFont.systemFontOfSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        
        self.setupViews()
    }
    required init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has nont been implemented")
    }
    
    private func setupViews() {
        
        self.replyBox.addSubview(replyContent)
        replyContent.snp_makeConstraints { (make) -> Void in
            make.left.top.equalTo(8)
            make.right.bottom.equalTo(-8)
        }
    }
    
}