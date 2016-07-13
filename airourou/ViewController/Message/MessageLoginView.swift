//
//  MessageLoginView.swift
//  爱肉肉
//
//  Created by isno on 16/2/14.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class MessageLoginView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    var loginCallback:(() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func  setupViews() {
        self.backgroundColor = UIColor.whiteColor()
        let image = UIImageView(image: UIImage(named: "chatNotLogin"))
        image.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(image)
        
        image.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.top.equalTo(120)
        }
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFontOfSize(16)
        title.textColor = UIColor(rgba: "#999")
        title.text = "登录后，你与好友的对话"
        
        self.addSubview(title)
        
        title.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.top.equalTo(image.snp_bottom).offset(30)
        }
        
        let intro = UILabel()
        intro.translatesAutoresizingMaskIntoConstraints = false
        intro.font = UIFont.systemFontOfSize(16)
        intro.textColor = UIColor(rgba: "#999")
        intro.text = "将会出现在这里"
        
        self.addSubview(intro)
        
        intro.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.top.equalTo(title.snp_bottom).offset(8)
        }
        
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.backgroundColor = UIConstant.FontLightColor
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgba: "#999").CGColor
        button.clipsToBounds = true
        button.setTitle("快速登录", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16)
        button.setTitleColor(UIColor(rgba: "#676767"), forState: .Normal)
        button.addTarget(self, action: #selector(MessageLoginView.loginClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)
        
        button.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(34)
            make.top.equalTo(intro.snp_bottom).offset(38)
        }
        
    }
    @objc private func loginClicked() {
        if self.loginCallback != nil {
            self.loginCallback!()
        }
    }
}