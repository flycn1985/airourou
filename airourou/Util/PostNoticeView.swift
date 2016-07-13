//
//  PostNoticeView.swift
//  爱肉肉
//
//  Created by isno on 16/3/2.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation

class PostNoticeView:NSObject {
    private var notices = Array<UIView>()
    private var window:UIWindow! = UIApplication.sharedApplication().keyWindow!
    static let sharedInstance = PostNoticeView()
    
    let maskView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.9, alpha: 0.4)
        return view
    }()
    
    let noticeView:PostFreeNoticeView = {
        let view = PostFreeNoticeView()
        return view
    }()
    
    func clearNotice() {
        for view in notices {
            view.removeFromSuperview()
        }
    }
    
    func show() {
        clearNotice()
       
        notices.append(noticeView)
        window.addSubview(maskView)
        notices.append(maskView)
        maskView.snp_makeConstraints(closure: { (make) -> Void in
            make.top.left.equalTo(0)
            make.height.equalTo(AppHeight)
            make.width.equalTo(AppWidth)
            })
        window.addSubview(noticeView)
        noticeView.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(120)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            })
    }
    
}