//
//  TimelineView.swift
//  爱肉肉
//
//  Created by isno on 16/4/12.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class TimelineView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    var addCallback:(() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func  setupViews() {
        self.backgroundColor = UIColor.whiteColor()
        self.hidden = true
        
        let intro = UILabel()
        intro.font = UIFont.boldSystemFontOfSize(18)
        intro.textColor = UIConstant.FontLightColor
        intro.text = "开启一段奇妙的时光之旅..."
        
        self.addSubview(intro)
        
        intro.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.top.equalTo(120)
        }
        
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.backgroundColor = UIConstant.FontLightColor
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgba: "#999").CGColor
        button.clipsToBounds = true
        button.setTitle("添加肉肉", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16)
        button.setTitleColor(UIColor(rgba: "#676767"), forState: .Normal)
        button.addTarget(self, action: #selector(TimelineView.loginClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)
        
        button.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(34)
            make.top.equalTo(intro.snp_bottom).offset(38)
        }
        
    }
    @objc private func loginClicked() {
        if self.addCallback != nil {
            self.addCallback!()
        }
    }
}