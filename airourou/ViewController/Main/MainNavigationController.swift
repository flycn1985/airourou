//
//  MainNavigationController.swift
//  爱肉肉
//
//  Created by isno on 16/1/5.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit


class MainNavigationController:UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.titleTextAttributes =  [NSForegroundColorAttributeName : UIColor(rgba: "#333"), ]
        self.navigationBar.tintColor = UIConstant.FontLightColor
        
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = false
        self.navigationBar.backgroundColor = UIColor(rgba: "#f9f9f9")
        
        
        self.navigationBar.layer.shadowColor = UIColor(rgba: "#b5b4b9").CGColor
        self.navigationBar.layer.shadowOffset = CGSizeMake(0,1)
        self.navigationBar.layer.shadowOpacity = 0.1
        self.navigationBar.layer.shadowRadius = 1
        
        
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        
        if self.childViewControllers.count > 0 {

            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(MainNavigationController.backBtnClick))
            
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    @objc private func backBtnClick() {
        self.popViewControllerAnimated(true)
    }
    
    
}
