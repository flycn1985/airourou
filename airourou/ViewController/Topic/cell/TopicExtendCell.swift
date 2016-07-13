//
//  TopicExtendCell.swift
//  爱肉肉
//
//  Created by isno on 16/3/7.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import WebKit

class TopicExtendCell:UITableViewCell{
    
    private var replyNum:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
         label.textColor = UIColor(rgba: "#adadad")
        return label
    }()
    
    private var likeNum:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(rgba: "#adadad")
        return label
    }()
    

    func bind(data:JSON) {
        let replyText = NSMutableAttributedString()
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = UIImage(named: "icon_reply")
        replyText.appendAttributedString(NSAttributedString(attachment: textAttachment))
        
        replyText.appendAttributedString(NSMutableAttributedString(string:" " + String(data["reply_count"].int!), attributes: [
            NSBaselineOffsetAttributeName: 8
            ]))
        self.replyNum.attributedText = replyText
        
        
        let likeText = NSMutableAttributedString()
        let likeAttachment = NSTextAttachment()
        
        likeAttachment.image = UIImage(named: "icon_like")
        likeText.appendAttributedString(NSAttributedString(attachment: likeAttachment))
        
        likeText.appendAttributedString(NSMutableAttributedString(string:" " + String(data["like_count"].int!), attributes: [
            NSBaselineOffsetAttributeName: 3
            ]))
        self.likeNum.attributedText = likeText
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        
        self.contentView.addSubview(self.likeNum)
        
        self.likeNum.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(8)
            make.right.equalTo(-12)
           
        }
        
        self.contentView.addSubview(replyNum)
        self.replyNum.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.likeNum.snp_centerY)
            make.width.equalTo(40)
            make.right.equalTo(self.likeNum.snp_left).offset(-12)
        }
        let bottomLine  = UIView()
        bottomLine.backgroundColor = UIConstant.AppBackgroundColor
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(bottomLine)
        
        bottomLine.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.replyNum.snp_bottom).offset(8)
            make.height.equalTo(20)
            make.right.equalTo(0)
            make.left.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        let Line  = UIView()
        Line.backgroundColor = UIColor(rgba: "#e0dfdf")
        self.contentView.addSubview(Line)
        Line.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(bottomLine.snp_top).offset(0)
            make.height.equalTo(0.5)
            make.right.equalTo(0)
            make.left.equalTo(0)
            
        }
        /*
        let Line2  = UIView()
        Line2.backgroundColor = UIColor(rgba: "#e8e7e7")
        self.contentView.addSubview(Line2)
        Line2.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(bottomLine.snp_bottom).offset(0)
            make.height.equalTo(0.5)
            make.right.equalTo(0)
            make.left.equalTo(0)
        }
        
        let label = UILabel()
        label.text = "评论"
        label.font = UIFont.boldSystemFontOfSize(15)
        label.textColor = UIColor(rgba:"#676767")
        
        self.contentView.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.top.equalTo(Line2.snp_bottom).offset(8)
            make.left.equalTo(12)
        }
        
        let Line3  = UIView()
        Line3.backgroundColor = UIConstant.AppBackgroundColor
        self.contentView.addSubview(Line3)
        Line3.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(label.snp_bottom).offset(8)
            make.height.equalTo(0.5)
            make.right.equalTo(0)
            make.left.equalTo(0)
            make.bottom.equalTo(-8)
        }
       */
       
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}