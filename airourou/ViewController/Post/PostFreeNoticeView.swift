//
//  FreeNoticeView.swift
//  爱肉肉
//
//  Created by isno on 16/3/2.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class PostFreeNoticeView:UIView {
    
    private let confirmButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("确定发布", forState: .Normal)
        button.setBackgroundImage(UIImage.imageWithColor(UIConstant.FontLightColor), forState: .Normal)
        
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        
        
        return button
    }()
    
    private let cancelButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("取消", forState: .Normal)
        button.backgroundColor = UIColor.whiteColor()
        button.setTitleColor(UIColor(rgba: "#444"), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        return button
    }()
    
    let tip1:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = UIColor(rgba: "#fff")
        return label
    }()
    
    let tip2:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor(rgba: "#fff")
        return label
    }()
    
    let tip3:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2、请按照肉友报名申请纪录来安排分享，如成功申请的花友符合分享条件，没有得到分享，经查实可能会扣除花币。"
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor(rgba: "#fff")
        return label
    }()
    
    var confirmComplete:(() -> Void)?
    var cancelComplete:(() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupViews() {
        self.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        self.addSubview(tip1)
        tip1.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(16)
            make.top.equalTo(16)
        }
        
        self.addSubview(tip2)
        tip2.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(16)
            make.top.equalTo(tip1.snp_bottom).offset(8)
            make.right.equalTo(-16)
        }
        
        self.addSubview(tip3)
        tip3.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(16)
            make.top.equalTo(tip2.snp_bottom).offset(8)
            make.right.equalTo(-16)
        }
        
        self.addSubview(confirmButton)
        confirmButton.addTarget(self, action: #selector(PostFreeNoticeView.confirmClicked), forControlEvents: .TouchUpInside)
        confirmButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(tip3.snp_bottom).offset(23)
            make.right.equalTo(self.snp_centerX).offset(-18)
            make.width.equalTo(90)
            make.height.equalTo(35)
        }
        
        self.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(PostFreeNoticeView.cancelClicked), forControlEvents: .TouchUpInside)
        cancelButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(tip3.snp_bottom).offset(23)
            make.left.equalTo(self.snp_centerX).offset(18)
            make.width.equalTo(90)
            make.height.equalTo(35)
            make.bottom.equalTo(-16)
        }
        
    }
    func confirmClicked() {
        if confirmComplete != nil {
            confirmComplete!()
        }
    }
    func cancelClicked() {
        if cancelComplete != nil {
            cancelComplete!()
        }
    }
}