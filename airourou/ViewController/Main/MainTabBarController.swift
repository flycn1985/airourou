//
//  MainTabBarController.swift
//  爱肉肉
//
//  Created by isno on 16/1/5.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController:UITabBarController {
    var id:Int = 0
    override func viewDidLoad() {
        self.tabBar.translucent = false
        //UITabBar.appearance().shadowImage  = UIImage()
        //UITabBar.appearance().backgroundImage = UIImage()
        
        
        /*
        self.tabBar.layer.shadowColor = UIColor.grayColor().CGColor
        self.tabBar.layer.shadowOffset = CGSizeMake(0,-2)
        self.tabBar.layer.shadowOpacity = 0.1
        self.tabBar.layer.shadowRadius = 1

        self.tabBar.layer.borderWidth = 0.50
        self.tabBar.layer.borderColor = UIColor(rgba: "#e4e4e4").CGColor
        */
        /**home*/
        
       
        //let tabbar = ARTabBar()
        //setValue(tabbar, forKey: "tabBar")
        

        
        self.addChildVCS(BbsViewController(), title: "首页", imageName: "tabbar_home_n", selectedImageName: "tabbar_home_s")
        self.addChildVCS(MessageViewController(), title: "消息", imageName: "tabbar_message_n", selectedImageName: "tabbar_message_s")
        self.addChildVCS(RecordViewController(), title: "时光", imageName: "tabbar_timeline", selectedImageName: "tabbar_timeline_hl")
        self.addChildVCS(MeViewController(), title: "我", imageName: "tabbar_me_n", selectedImageName: "tabbar_me_s")
        
        /*
        tabbar.composeButtonClicked = {
            weak var weakSelf = self
            let vc = MainNavigationController(rootViewController: PostViewController())
            weakSelf!.modalTransitionStyle = .CrossDissolve
            self.presentViewController(vc, animated: true, completion: {})
        }*/
        
    }

    
    private func addChildVCS(vc: UIViewController, title: String, imageName: String, selectedImageName: String) {
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysOriginal), selectedImage: UIImage(named: selectedImageName)!.imageWithRenderingMode(.AlwaysOriginal))
        vc.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(rgba: "#666")], forState:.Selected)
        
        addChildViewController(MainNavigationController(rootViewController: vc))
    }
}
