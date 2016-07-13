//
//  MessageViewController.swift
//  爱肉肉
//
//  Created by isno on 16/1/5.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SwiftHTTP

class MessageViewController:RCConversationListViewController {
    
    let headView = MessageHeadView()
    let loginView = MessageLoginView()
    
    private var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "消息"
        self.setDisplayConversationTypes([RCConversationType.ConversationType_PRIVATE.rawValue,RCConversationType.ConversationType_SYSTEM.rawValue])
        self.conversationListTableView.separatorColor =  UIColor(rgba: "#f1f2f2")
        
        loginView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loginView)
        loginView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        loginView.loginCallback = {
             self.navigationController!.pushViewController(LoginViewController(), animated: true)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image:  UIImage(named: "icon_set"), style: .Plain, target: self, action: #selector(MessageViewController.settingClicked))
        
        
        self.conversationListTableView.backgroundColor = UIConstant.AppBackgroundColor
        
        headView.SystemComplete = {
            let vc = SystemNoticeViewController()
            vc.type = "system"
            vc.title = "系统通知"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        headView.LikeComplete = {
            let vc = SystemNoticeViewController()
            vc.type = "like"
            vc.title = "喜欢"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        headView.ReplyComplete = {
            let vc = SystemNoticeViewController()
            vc.type = "reply"
            vc.title = "回复"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        headView.frame = CGRectMake(0, 0, AppWidth, 152)
        self.conversationListTableView.tableHeaderView = headView
        self.conversationListTableView.tableFooterView = nil
        
    }

    func showEmptyConversationView(){
        
    }
    
    
    @objc private func settingClicked() {
        self.navigationController?.pushViewController(MessageSettingViewController(), animated: true)
    }
    
    override func onSelectedTableRow(conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, atIndexPath indexPath: NSIndexPath!) {
        let chat = MessageItemViewController(conversationType: model.conversationType, targetId: model.targetId!)
        chat.title = "与" + model.conversationTitle + "私聊中"
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    override func didTapCellPortrait(model: RCConversationModel!) {
        let vc = UserPageViewController()
        vc.UserId = Int(model.targetId!)!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.notifyUpdateUnreadMessageCount()
        if AuthHelper.sharedInstance.isLogin() == false {
            loginView.hidden = false
        } else {
            loginView.hidden = true

            let opt = try! HTTP.GET(UIConstant.AppDomain+"notice/unread_num")
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data:response.data)
                    if json["error_code"].int == 0 {
                        dispatch_sync(dispatch_get_main_queue()) {
                            
                            if json["system_count"].int > 0 {
                                self.headView.systemBadge.hidden = false
                                self.headView.systemBadge.text = String(json["system_count"].int!)
                            } else {
                                self.headView.systemBadge.hidden = true
                            }
                            
                            if json["like_count"].int > 0 {
                                self.headView.likeBadge.hidden = false
                                self.headView.likeBadge.text = String(json["like_count"].int!)
                            } else {
                                self.headView.likeBadge.hidden = true
                            }
                            
                            
                            if json["reply_count"].int > 0 {
                                self.headView.replyBadge.hidden = false
                                self.headView.replyBadge.text = String(json["reply_count"].int!)
                            } else {
                                self.headView.replyBadge.hidden = true
                            }
                            
                            let unreadNum = RCIMClient.sharedRCIMClient().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue,RCConversationType.ConversationType_SYSTEM.rawValue])
                            let unreadCount = json["unread_count"].int! + unreadNum
                            if unreadCount > 0 {
                                self.tabBarItem.badgeValue = String(unreadCount)
                            } else {
                                self.tabBarItem.badgeValue = nil
                            }
                            
                        }
                    }
                }
            }
            
   
        }
        self.view.bringSubviewToFront(loginView)
    }
    override func notifyUpdateUnreadMessageCount() {
        self.updateBadgeValueForTabBarItem()
    }
    func updateBadgeValueForTabBarItem() {
        dispatch_async(dispatch_get_main_queue(), {
            let unreadNum = RCIMClient.sharedRCIMClient().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue,RCConversationType.ConversationType_SYSTEM.rawValue])
            
            if (unreadNum>0) {
                UIApplication.sharedApplication().applicationIconBadgeNumber = Int(unreadNum)
                self.tabBarItem.badgeValue = String(unreadNum)
                
            } else {
                self.tabBarItem.badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                
            }
        })
    }
}

