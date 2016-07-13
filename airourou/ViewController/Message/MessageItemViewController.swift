//
//  MessageItemController.swift
//  airourou
//
//  Created by isno on 15/12/20.
//  Copyright © 2015年 isno. All rights reserved.
//

import Foundation
import SVProgressHUD

class MessageItemViewController:RCConversationViewController {
    override  func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let barButton = UIBarButtonItem()
        barButton.title = ""
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        
         self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_more"), style: .Plain, target: self, action: #selector(MessageItemViewController.optClicked))
        
    }
    @objc private func optClicked() {
        
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        vc.addAction(UIAlertAction(title: "清空聊天记录", style: .Destructive, handler: { _ in
            SVProgressHUD.show()
            RCIMClient.sharedRCIMClient().clearMessages(RCConversationType.ConversationType_PRIVATE, targetId: self.targetId)
            SVProgressHUD.showSuccessWithStatus("清空聊天记录成功")
        }))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func didTapCellPortrait(userId: String!) {
        let vc = UserPageViewController()
        vc.UserId = Int(userId)!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



