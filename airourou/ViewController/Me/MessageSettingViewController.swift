//
//  MessageSettingViewController.swift
//  爱肉肉
//
//  Created by isno on 16/2/16.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import Eureka
import SwiftyJSON
import SwiftHTTP
import SVProgressHUD

class MessageSettingViewController:FormViewController {
    
    let notifyRow =  SwitchRow("notify"){
        $0.title = "新消息提醒"
        $0.value = NotifyHelper.sharedInstance.getValue("notify")
    }
    
    let notifyReplyRow = SwitchRow("notify_reply"){
        $0.title = "帖子回复提醒"
        $0.value = NotifyHelper.sharedInstance.getValue("notify_reply")
    }
    
    let notifyLikeRow = SwitchRow("notify_like"){
        $0.title = "帖子收藏提醒"
        $0.value = NotifyHelper.sharedInstance.getValue("notify_like")
    }
    
    let notifyAtRow = SwitchRow("notify_at"){
        $0.title = "回复at提醒"
        $0.value = NotifyHelper.sharedInstance.getValue("notify_at")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "消息设置"
        
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        tableView?.backgroundColor = UIConstant.AppBackgroundColor
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView!.separatorColor = UIColor(rgba: "#e3e3e4")
        tableView?.layer.borderColor = UIColor.whiteColor().CGColor
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont.systemFontOfSize(15)
            cell.textLabel?.textColor = UIColor(rgba: "#000")
        }

        
        tableView?.sectionIndexBackgroundColor  = UIColor.whiteColor()
        /*
        form +++ Section()
            <<< notifyRow.onChange({ (SwitchRow) -> () in
                var on = 0
                if SwitchRow.value! == true {
                    on = 1
                }
                
                AirouApi.sharedInstance.request(.SettingNotify(type:"new_message", on:on), completion: { (result) -> () in
                    switch(result) {
                    case let .Success(response):
                        let json = JSON(data:response.data)
                        if json["error_code"].int != 0 {
                            SVProgressHUD.showErrorWithStatus("保存失败")
                        } else {
                            NotifyHelper.sharedInstance.set("new_message", value: SwitchRow.value!)
                        }
                        break
                    default:break
                    }
                })
                
            })
            */
           form +++ Section()
            <<< notifyReplyRow.onChange({ (SwitchRow) -> () in
                    var on = 0
                    if SwitchRow.value! == true {
                        on = 1
                    }
                let params:Dictionary<String,AnyObject>= [
                        "type":"reply",
                        "on":on
                ]
                let opt = try! HTTP.POST(UIConstant.AppDomain+"setting/notify", parameters: params)
                opt.start { response in
                    dispatch_sync(dispatch_get_main_queue()) {
                        let json = JSON(data:response.data)
                        if json["error_code"].int != 0 {
                            SVProgressHUD.showErrorWithStatus("保存失败")
                        } else {
                            NotifyHelper.sharedInstance.set("reply", value: SwitchRow.value!)
                        }
                        
                    }
                    
                }
            })
            <<< notifyLikeRow.onChange({ (SwitchRow) -> () in
                    var on = 0
                    if SwitchRow.value! == true {
                        on = 1
                    }
                    
                let params:Dictionary<String,AnyObject>= [
                    "type":"like",
                    "on":on
                ]
                let opt = try! HTTP.POST(UIConstant.AppDomain+"setting/notify", parameters: params)
                opt.start { response in
                    dispatch_sync(dispatch_get_main_queue()) {
                        let json = JSON(data:response.data)
                        if json["error_code"].int != 0 {
                            SVProgressHUD.showErrorWithStatus("保存失败")
                        } else {
                            NotifyHelper.sharedInstance.set("reply", value: SwitchRow.value!)
                        }
                        
                    }
                    
                }
                
                })

            <<< notifyAtRow.onChange({ (SwitchRow) -> () in
                    var on = 0
                    if SwitchRow.value! == true {
                        on = 1
                    }
                    
                let params:Dictionary<String,AnyObject>= [
                    "type":"at",
                    "on":on
                ]
                let opt = try! HTTP.POST(UIConstant.AppDomain+"setting/notify", parameters: params)
                opt.start { response in
                    dispatch_sync(dispatch_get_main_queue()) {
                        let json = JSON(data:response.data)
                        if json["error_code"].int != 0 {
                            SVProgressHUD.showErrorWithStatus("保存失败")
                        } else {
                            NotifyHelper.sharedInstance.set("reply", value: SwitchRow.value!)
                        }
                        
                    }
                    
                }

                
                })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        notifyRow.value =  NotifyHelper.sharedInstance.getValue("new_message")
        notifyReplyRow.value =  NotifyHelper.sharedInstance.getValue("reply")
        notifyLikeRow.value =  NotifyHelper.sharedInstance.getValue("like")
        notifyAtRow.value =  NotifyHelper.sharedInstance.getValue("at")
    }
}