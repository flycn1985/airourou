//
//  TopicCell.swift
//  爱肉肉
//
//  Created by isno on 16/1/18.
//  Copyright © 2016年 isno. All rights reserved.
//
import UIKit
import SwiftyJSON


class TopicBoardBasicCell:UITableViewCell {
    var showUserComplete:((userId:Int) -> Void)?
    
    var data:JSON!
    var pics:JSON!
}

class TopicCell:TopicBoardBasicCell {
    var boxView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgba: "#fff")
        return view
    }()
    
    // 图片box
    var imageBoxView:UIView!
    
    // 用户资料
    private var avatarView:UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 38/2
        view.clipsToBounds = true
        return view
    }()
    /**
     用户昵称
     */
    private var nickname:UILabel = {
        let name = UILabel()
        name.textColor = UIColor(rgba: "#3a3a3a")
        name.font = UIFont.systemFontOfSize(14)
        return name
    }()
    

    
    private var isAdmin:UILabel = {
        let name = UILabel()
        name.textColor = UIColor.whiteColor()
        name.font = UIFont.systemFontOfSize(11)
        name.backgroundColor = UIColor(rgba: "#f90")
        name.text = "管理员"
        name.layer.cornerRadius = 5
        name.clipsToBounds = true
        name.textAlignment = .Center
        name.layer.borderWidth = 0.5
        name.layer.borderColor = UIColor(rgba: "#e68e09").CGColor
        name.hidden = false
        return name
    }()
    
    // 帖子创建时间
    private var createdAt:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#adadad")
        label.font = UIFont.systemFontOfSize(13)
        return label
    }()
    
    private var signature:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#adadad")
        label.font = UIFont.systemFontOfSize(13)
        return label
    }()
    
    /** 帖子标题 */
    private var title:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font          = UIFont.systemFontOfSize(18)
        label.textColor     = UIColor(rgba: "#555")
        return label
    }()
    
    /** 帖子内容 */
    private var content:UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        label.font          = UIFont.systemFontOfSize(15)
        label.textColor     = UIColor(rgba: "#787878")
        return label
    }()
    
    private var likeNum:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        
        return label
    }()
    
    private var replyNum:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        
        return label
    }()
    
    
    private var location:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        return label
    }()
    
    private var shareView:UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_topic_share"))
        return view
    }()
    
    private var forwardButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named:"icon_forward"), forState: .Normal)
        button.setTitle("分享", forState: .Normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(UIColor(rgba: "#555"), forState: .Normal)
        return button
    }()
    
    private var bestIcon:UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_topic_best"))
        return view
    }()
    
    var levelIconView:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
 
    override var data:JSON! {
        didSet {
            self.avatarView.ar_setImageWithURL(data["user"]["avatar_url"].string!)
            self.avatarView.tag = data["user"]["_id"].int!
            self.nickname.text  = data["user"]["nickname"].string
            self.nickname.tag = data["user"]["_id"].int!
            self.createdAt.text = data["created_at"].string
            
            self.levelIconView.image = UIImage(named: "level\(data["user"]["level"].int!).png")
            
            self.signature.text = data["user"]["signature"].string
            
            self.likeNum.attributedText = self.getLikeNumText(data["like_count"].int!, isLike: data["is_like"].bool!)
            self.replyNum.attributedText = self.getReplyNumText(data["reply_count"].int!)
            
            if data["place"].string == "" {
                location.hidden = true
            } else {
                location.attributedText = self.getLocationText(data["place"].string!)
                location.hidden = false
            }
            if data["type"].string == "share" {
                if data["share"]["leavings_num"].int == 0 {
                    shareView.hidden = false
                } else {
                    shareView.hidden = true
                }
                
            } else {
                shareView.hidden = true
            }
            
            if data["is_best"].bool == true {
                bestIcon.hidden = false
            } else {
                bestIcon.hidden = true
            }
            
            if data["user"]["is_show_admin"].bool == true {
                self.isAdmin.hidden = false
            } else {
                self.isAdmin.hidden = true
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            
            let  attrString = NSMutableAttributedString(string:data["content"].string!)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            
            self.content.attributedText = attrString
            
            let title = NSMutableAttributedString()
            if data["type"].string! == "ask" {
                if data["coin"].int > 0 {
                    let coin = "\(data["coin"].int!)肉票"
                    title.appendAttributedString(self.getAskCoinText(coin))
                }
            }
            
            if data["type"].string! == "exchange" {
                title.appendAttributedString(NSMutableAttributedString(string:"交换", attributes: [
                    NSForegroundColorAttributeName : UIColor(rgba: "#00bb9c")]))
            } else if data["type"].string! == "share" {
                title.appendAttributedString(NSMutableAttributedString(string:"分享",attributes: [
                    NSForegroundColorAttributeName : UIConstant.FontLightColor]))
                
            }
            
            title.appendAttributedString(NSMutableAttributedString(string:data["title"].string!))
            self.title.attributedText = title
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        
        self.backgroundColor = UIConstant.AppBackgroundColor
        
        self.setupViews()
        self.boxView.bringSubviewToFront(bestIcon)
    }
    /** 获取评论文本 */
    private func getReplyNumText(replyNum:Int) -> NSMutableAttributedString {
        let text = NSMutableAttributedString()
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = UIImage(named: "icon_reply")
        text.appendAttributedString(NSAttributedString(attachment: textAttachment))
        
        text.appendAttributedString(NSMutableAttributedString(string:" " + String(replyNum), attributes: [
            NSForegroundColorAttributeName : UIColor(rgba: "#adadad"),
            NSBaselineOffsetAttributeName: 8
            ]))
        return text
    }
    /** 获取 喜欢文本  */
    private func getLikeNumText(likeNum:Int, isLike:Bool) -> NSMutableAttributedString {
        let text = NSMutableAttributedString()
        let textAttachment = NSTextAttachment()
        if isLike == true {
            textAttachment.image = UIImage(named: "icon_like_hl")
        } else {
            textAttachment.image = UIImage(named: "icon_like")
        }
        
        text.appendAttributedString(NSAttributedString(attachment: textAttachment))
        text.appendAttributedString(NSMutableAttributedString(string:" " + String(likeNum), attributes: [
            NSForegroundColorAttributeName : UIColor(rgba: "#adadad"),
            NSBaselineOffsetAttributeName: 3
            ]))
        return text
    }
    
    func getLocationText(address:String) -> NSMutableAttributedString {
        let text = NSMutableAttributedString()
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = UIImage(named: "icon_location")
        text.appendAttributedString(NSAttributedString(attachment: textAttachment))
        
        text.appendAttributedString(NSMutableAttributedString(string:address, attributes: [
            NSForegroundColorAttributeName : UIColor(rgba: "#bdbdbd"),
            NSBaselineOffsetAttributeName: 3
            ]))
        return text
    }
    
    func getAskCoinText(coin:String) -> NSMutableAttributedString {
        let text = NSMutableAttributedString()
        let textAttachment = NSTextAttachment()
        
        
        textAttachment.image = UIImage(named: "icon_coin")
        text.appendAttributedString(NSAttributedString(attachment: textAttachment))
        
        
        text.appendAttributedString(NSMutableAttributedString(string:coin, attributes: [
            NSForegroundColorAttributeName : UIConstant.FontLightColor,
            NSFontAttributeName:UIFont.boldSystemFontOfSize(16),
            NSBaselineOffsetAttributeName: 0,
            ]))
        return text
    }
    private func setupViews() {
        
        
        self.contentView.addSubview(self.boxView)
        
        self.boxView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(12)
            make.height.greaterThanOrEqualTo(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }

        self.boxView.addSubview(self.shareView)
        
        self.shareView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(-1)
            make.right.equalTo(0)
        }

        
        /** 头像 */
        self.avatarView.userInteractionEnabled = true
        
        let tapGR = UITapGestureRecognizer(target:self, action: #selector(TopicCell.avatarViewPressed(_:)))
        self.avatarView.addGestureRecognizer(tapGR)
        
        self.boxView.addSubview(self.avatarView)
        
        self.avatarView.snp_makeConstraints { (make) -> Void in
            make.top.left.equalTo(self.boxView).offset(8)
            make.size.equalTo(38)
        }
        
        self.boxView.addSubview(self.levelIconView)
        levelIconView.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.width.equalTo(16)
            make.right.equalTo(self.avatarView.snp_right).offset(3)
            make.bottom.equalTo(self.avatarView.snp_bottom).offset(-3)
        }
        
        
        /** 昵称 */
        self.nickname.userInteractionEnabled = true
        self.boxView.addSubview(nickname)
        let tapUserGR = UITapGestureRecognizer(target:self, action: #selector(TopicCell.avatarViewPressed(_:)))
        self.nickname.addGestureRecognizer(tapUserGR)
        self.nickname.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.avatarView.snp_right).offset(8)
            make.top.equalTo(self.avatarView.snp_top).offset(3)
        }

        
        self.boxView.addSubview(isAdmin)
        self.isAdmin.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.nickname.snp_right).offset(8)
            make.width.equalTo(48)
            make.height.equalTo(15)
            make.centerY.equalTo(self.nickname.snp_centerY)
        }
        
        
        
        /** 创建时间*/
        self.boxView.addSubview(self.createdAt)
        
        self.createdAt.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(16)
            make.right.equalTo(-16)
        }
        
        /** 创建时间*/
        self.boxView.addSubview(self.signature)
        
        self.signature.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.nickname.snp_bottom).offset(2)
            make.left.equalTo(self.avatarView.snp_right).offset(8)
        }
        
        self.boxView.addSubview(self.bestIcon)
        self.bestIcon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.signature)
            make.left.equalTo(self.signature.snp_right).offset(8)
        }
        
        /** 标题 */
        self.boxView.addSubview(self.title)
        
        self.title.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatarView.snp_bottom).offset(8)
            make.left.equalTo(self.boxView).offset(8)
            make.right.equalTo(self.boxView).offset(-8)
        }
        
        /** 内容 */

        self.boxView.addSubview(self.content)
        
        self.content.snp_updateConstraints { (make) -> Void in
            make.top.equalTo(title.snp_bottom).offset(8)
            make.left.equalTo(self.boxView).offset(8)
            make.right.equalTo(self.boxView).offset(-8)
        }
        
        /** 图片 */
        self.imageBoxView = UIView()
        self.boxView.addSubview(self.imageBoxView)
        
        self.imageBoxView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.content.snp_bottom).offset(8)
            make.left.equalTo(boxView).offset(0)
            make.right.equalTo(boxView).offset(0)
        }

        self.boxView.addSubview(self.location)
        
        self.location.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(imageBoxView.snp_bottom).offset(8)
            make.left.equalTo(8)
        }
        
        self.boxView.addSubview(self.replyNum)
        
        self.replyNum.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-8)
            make.top.equalTo(imageBoxView.snp_bottom).offset(8)
            make.width.equalTo(40)
            
        }
               /** 主题附属信息 */
        self.boxView.addSubview(self.likeNum)
        
        self.likeNum.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(replyNum.snp_left).offset(-8)
            make.top.equalTo(imageBoxView.snp_bottom).offset(12)
            make.width.equalTo(40)
            make.bottom.equalTo(-12)
        }

        
        
    }
    
    func avatarViewPressed(tap : UITapGestureRecognizer){
        if self.showUserComplete != nil {
            self.showUserComplete!(userId:tap.view!.tag)
        }
    }
}