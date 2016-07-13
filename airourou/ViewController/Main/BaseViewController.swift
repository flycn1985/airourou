//
//  BaseViewController.swift
//  airourou
//
//  Created by isno on 16/5/3.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController:UIViewController {
    private weak var _loadView:LoadingView?
    
    func showLoadingView (){
        
        self.hideLoadingView()
        
        let aloadView = LoadingView()
        aloadView.backgroundColor = UIConstant.AppBackgroundColor
        self.view.addSubview(aloadView)
        aloadView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view)
        }
        self._loadView = aloadView
    }
    func hideLoadingView() {
        self._loadView?.removeFromSuperview()
    }
}