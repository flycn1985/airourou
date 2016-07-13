//
//  LoadingView.swift
//  爱肉肉
//
//  Created by isno on 16/1/18.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class LoadingView:UIView {
    
    var activityIndicatorView:UIActivityIndicatorView?
    
    init () {
        super.init(frame:CGRectZero)
        
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.addSubview(self.activityIndicatorView!)
        self.activityIndicatorView!.snp_makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(0)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        self.activityIndicatorView?.startAnimating()
    }
    func hide(){
        self.superview?.bringSubviewToFront(self)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.alpha = 0
            }) { (finished) -> Void in
            if finished {
                self.removeFromSuperview()
            }
        }
    }
    
}