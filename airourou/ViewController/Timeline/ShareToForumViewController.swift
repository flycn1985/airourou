//
//  ShareToForumViewController.swift
//  airourou
//
//  Created by 夏菁 on 15/11/13.
//  Copyright © 2015年 isno. All rights reserved.
//

import UIKit
import SVProgressHUD
import Eureka
import WebKit
import SwiftyJSON
import SwiftHTTP


class AirouBoard:NSObject {
        var name:String = ""
        var id:Int = 0
        
        convenience init(id:Int, name:String) {
            self.init()
            self.id = id
            self.name = name
        }
        override internal var description:String {
            return self.name
        }
}


class ShareToForumViewController: FormViewController {
    
    var RecordId = 0
    var StatusesId = 0
    
    var webView:WKWebView! = nil
    
    var titleRow =  TextRow("title"){
            $0.title = "标题"
        }
    override func viewDidLoad() {
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: UITableViewStyle.Plain)
            tableView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleHeight)
        }
        super.viewDidLoad()
        self.title = "分享至论坛"
        self.view.backgroundColor = UIColor.whiteColor()
        
        // 发布按钮
        let postBtn = UIBarButtonItem(title: "发贴", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ShareToForumViewController.postToForum))
        navigationItem.rightBarButtonItem = postBtn
        
        // 设置子视图
        setupViews()
        
    }
    func postToForum() {
        let data =  self.form.values()
        guard let _ = data["title"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写帖子标题")
            return
        }
        let  board = data["board"] as! AirouBoard
        if board.id == 0 {
            SVProgressHUD.showErrorWithStatus("请选择论坛分类")
            return
        }

        webView.getContent { con in
            let parmas:Dictionary<String,AnyObject> = [
                "title":data["title"] as! String,
                "board_id":board.id,
                "html_source":con
            ]
            let opt = try! HTTP.POST(UIConstant.AppDomain+"timeline/topic", parameters: parmas)
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data:response.data)
                        dispatch_sync(dispatch_get_main_queue()) {
                            
                             if json["error_code"].int == 0 {
                                SVProgressHUD.showSuccessWithStatus(json["message"].string)
                                self.navigationController?.popViewControllerAnimated(true)
                                
                             } else {
                                SVProgressHUD.showErrorWithStatus(json["message"].string)
                            }
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    func setupViews() {
        
        tableView?.backgroundColor  = UIColor.whiteColor()
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView!.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView?.layer.borderColor = UIColor.whiteColor().CGColor
        tableView?.scrollEnabled = false
        tableView?.sectionIndexBackgroundColor  = UIColor.whiteColor()
        
        form +++ Section() { section in
            section.header = .None
            }
            <<< titleRow.cellUpdate({ (cell, row) in
                cell.textField.font = UIFont.systemFontOfSize(16)
                cell.textField.placeholder = "请填写帖子标题"
            })
            <<< PushRow<AirouBoard>("board") { row  in
                row.title = "板块"
                row.value = AirouBoard(id:0, name: "请选择论坛")
                
            }.cellSetup({ (cell, row) in
                let opt = try! HTTP.GET(UIConstant.AppDomain+"timeline/share/boards", parameters: ["record_id":self.RecordId])
                opt.start { response in
                    
                    if response.error == nil {
                    let json = JSON(data:response.data)
                    if json["error_code"].int == 0 {
                        dispatch_sync(dispatch_get_main_queue()) {
                            for _board in json["boards"] {
                                let obj = AirouBoard(id: _board.1["_id"].int!, name:  _board.1["name"].string!)
                                row.options.append(obj)
                            }
                            row.updateCell()
                          
                        }
                    }
                }
            }

        })

        
        tableView?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(100)
        })
        
        let name = UILabel()
        name.text = "正文"
        name.font = UIFont.systemFontOfSize(17)
        
        self.view.addSubview(name)
        name.snp_makeConstraints { (make) in
            make.top.equalTo((self.tableView?.snp_bottom)!).offset(0)
            make.left.equalTo(16)
        }
        
        let line = UIView()
        line.backgroundColor = UIConstant.AppBackgroundColor
        self.view.addSubview(line)
        line.snp_makeConstraints { (make) in
            make.top.equalTo(name.snp_bottom).offset(8)
            make.right.left.equalTo(0)
            make.height.equalTo(1)
        }
        
        let config = WKWebViewConfiguration()
        
        config.preferences = WKPreferences()
        
        config.preferences.javaScriptEnabled = true

        webView = WKWebView(frame:CGRectZero, configuration: config)

        self.view.addSubview(webView)
        webView.snp_makeConstraints { (make) in
            make.top.equalTo(line.snp_bottom).offset(8)
            make.left.equalTo(8)
            make.right.bottom.equalTo(-8)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let opt = try! HTTP.GET(UIConstant.AppDomain+"timeline/topic", parameters: ["record_id":self.RecordId, "statuses_id":self.StatusesId])
        opt.start { response in
            if response.error == nil {
                let json = JSON(data:response.data)
                if json["error_code"].int == 0 {
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.webView.loadHTMLString(json["html_source"].string!, baseURL: NSURL(string: "http://www.airourou.me"))
                        
                        self.titleRow.value = json["title"].string
                        self.titleRow.updateCell()
                    }
                }
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

