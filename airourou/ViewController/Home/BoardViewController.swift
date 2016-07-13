//
//  IndexViewController.swift
//  爱肉肉
//
//  Created by isno on 16/1/14.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

import MJRefresh
import SwiftyJSON

import SVProgressHUD
import PageMenu

class BoardViewController:UIViewController {
    
    var pageMenu : CAPSPageMenu?
    
    private var controllerArray : [UIViewController] = []
    
    var boardType:String = ""
    
    var BoardId:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let postButton = UIBarButtonItem(image: UIImage(named: "icon_post_new"), style: .Plain, target: self, action: #selector(BoardViewController.postNew))

        self.navigationItem.rightBarButtonItem = postButton
        
        let parameters: [CAPSPageMenuOption] = [
            .SelectedMenuItemLabelColor(UIConstant.FontLightColor),
            .UnselectedMenuItemLabelColor(UIColor(rgba:"#939395")),
            .ScrollMenuBackgroundColor(UIColor(rgba: "#f8f9fa")),
            .ViewBackgroundColor(UIColor.whiteColor()),
            .SelectionIndicatorColor(UIConstant.FontLightColor),
            .BottomMenuHairlineColor(UIColor(rgba:"#f2f2f2")),
            
            .MenuItemFont(UIFont.boldSystemFontOfSize(14)),
            .MenuHeight(32.0),
            .MenuItemWidth(60.0),

            .CenterMenuItems(true)
        ]
        
        let vc = BoardDetailViewController()
        vc.title = "最新"
        vc.view.backgroundColor = UIColor.redColor()
        vc.Type = "new"
        controllerArray.append(vc)
        
        let vc2 = BoardDetailViewController()
        vc2.title = "一周热门"
        vc2.Type = "hot"
        vc2.view.backgroundColor = UIColor.blackColor()
        controllerArray.append(vc2)
        
        let vc3 = BoardDetailViewController()
        vc3.title = "视觉党"
        vc3.Type = "pic"
        vc3.view.backgroundColor = UIColor.blackColor()
        controllerArray.append(vc3)
        
        let vc4 = BoardDetailViewController()
        vc4.title = "纯技术"
        vc4.Type = "skill"
        vc4.view.backgroundColor = UIColor.blackColor()
        controllerArray.append(vc4)
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        pageMenu!.delegate = self
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        
        pageMenu!.didMoveToParentViewController(self)
        
        //setupTableView()
    }
    
    func postNew() {
        
        if AuthHelper.sharedInstance.isLogin() == false {
            self.navigationController?.pushViewController(LoginViewController(), animated: true)
            return
        }
        
        let defaultVc = PostViewController()
        defaultVc.BoardId = self.BoardId
        
        switch(self.boardType) {
            case "share":
                let vc = UIAlertController(title:nil, message: "请选择发布主题类型", preferredStyle:.ActionSheet)
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                vc.addAction(cancelAction)
                
                let shareAction = UIAlertAction(title: "分享赠送", style: .Destructive, handler: { _ in
                    let vc = SharePostViewController()
                    vc.showNotice()
                    vc.BoardId = self.BoardId
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                
                let exchangeAction = UIAlertAction(title: "交换", style: .Default, handler: { _ in
                    let vc = ExchangePostViewController()
                    vc.BoardId = self.BoardId
                    vc.showNotice()
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                vc.addAction(shareAction)
                vc.addAction(exchangeAction)
                
                self.presentViewController(vc, animated: true, completion: nil)
            break
            case "ask":
                let vc = AskPostViewController()
                vc.BoardId = self.BoardId
                self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            self.navigationController?.pushViewController(defaultVc, animated: true)
            break
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let view = self.controllerArray[0] as! BoardDetailViewController
        view.BoardId = self.BoardId
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BoardViewController:CAPSPageMenuDelegate {
    func willMoveToPage(controller: UIViewController, index: Int){
        let view = self.controllerArray[index] as! BoardDetailViewController
        view.BoardId = self.BoardId
        view.reloadData()
    }
    
    func didMoveToPage(controller: UIViewController, index: Int){}
}



