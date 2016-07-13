//
//  BoardDetailViewController.swift
//  爱肉肉
//
//  Created by isno on 16/2/14.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SwiftHTTP

import MJRefresh
import SwiftyJSON

import SVProgressHUD


class BoardDetailViewController:BaseViewController {
    
    /** 表格 */
    private var _tableView :UITableView!
    private var tableView:UITableView  {
        get {
            if(_tableView != nil){
                return _tableView!
            }
            _tableView = UITableView()
            _tableView.delegate = self
            _tableView.dataSource = self
            
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            _tableView.estimatedRowHeight = 44.0
            _tableView.rowHeight = UITableViewAutomaticDimension
            _tableView.backgroundColor = UIConstant.AppBackgroundColor
            
            _tableView.registerClass(TopicCell.self, forCellReuseIdentifier:"topic") // 置顶
            _tableView.registerClass(TopicTopCell.self, forCellReuseIdentifier:"topic_top") // 置顶
            _tableView.registerClass(TopicImageOneCell.self, forCellReuseIdentifier: "topic_image_one")
            _tableView.registerClass(TopicImageTwoCell.self, forCellReuseIdentifier: "topic_image_two")
            _tableView.registerClass(TopicImageThreeCell.self, forCellReuseIdentifier: "topic_image_three")
            return _tableView
        }
    }
    
    private var topics = [JSON]()
    private var page:Int = 1
    private var boardType:String = ""
    
    var Type = "new"
    
    var BoardId:Int = 0 {
        didSet {
            
            self.reloadData()
        }
    }
    /* 重新载入 */
    func reloadData() {
        self.topics = [JSON]()
        self.showLoadingView()
        let params:Dictionary<String,AnyObject> = ["type":self.Type, "last_id":0]
        let opt = try! HTTP.GET(UIConstant.AppDomain+"board/\(self.BoardId)", parameters: params)
        self.topics = [JSON]()
        opt.start { response in
            if response.error == nil {
                let json = JSON(data:response.data)
                self.boardType = json["board_type"].string!
                for _topic in json["topics"] {
                    self.topics.append(_topic.1)
                }
                dispatch_sync(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    self.hideLoadingView()
                }
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        
        /** uitable */
        self.view.addSubview(self.tableView)
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        let header = RefreshHeader (refreshingBlock: { () -> Void in
            let params:Dictionary<String,AnyObject> = ["type":self.Type, "last_id":0]
            let opt = try! HTTP.GET(UIConstant.AppDomain+"board/\(self.BoardId)", parameters: params)
            
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data:response.data)
                    self.boardType = json["board_type"].string!
                    self.topics = [JSON]()
                    for _topic in json["topics"] {
                        self.topics.append(_topic.1)
                    }
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.tableView.mj_header.endRefreshing()
                        self.tableView.reloadData()
                    }
                }
            }
        })
       
        self.tableView.mj_header = header
        // end header
        
        let footer = RefreshFooter { () -> Void in
            var lastId = 0
            if self.topics.count > 0 {
                lastId = self.topics.last!["_id"].int!
            }
            let params:Dictionary<String,AnyObject> = ["type":self.Type, "last_id":lastId]
            let opt = try! HTTP.GET(UIConstant.AppDomain+"board/\(self.BoardId)", parameters: params)
            
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data:response.data)
                    for _topic in json["topics"] {
                        self.topics.append(_topic.1)
                    }
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.tableView.mj_footer.endRefreshing()
                        if json["topics"].count > 0 {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    
        
        self.tableView.mj_footer = footer
        // end footer
    }
    func postNew() {
        
        if AuthHelper.sharedInstance.isLogin() == false {
            SVProgressHUD.showErrorWithStatus("抱歉，你还未登录")
            return
        }
        switch(self.boardType) {
        case "share":
            let vc = UIAlertController(title: "请选择发布主题类型", message: nil, preferredStyle: .ActionSheet)
            vc.addAction(UIAlertAction(title: "免费赠送", style: .Destructive, handler: { (_) in
                self.navigationController?.pushViewController(SharePostViewController(), animated: true)
            }))
            vc.addAction(UIAlertAction(title: "交换", style: .Default, handler: { _ in
                   self.navigationController?.pushViewController(PostViewController(), animated: true)
                }))
           
            vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            self.presentViewController(vc, animated: true, completion: nil)
            break
        case "ask":
            self.navigationController?.pushViewController(AskPostViewController(), animated: true)
            break
        default:
            self.navigationController?.pushViewController(PostViewController(), animated: true)
            break
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BoardDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.tableViewDisplayWitMsg("暂时还没有帖子！", rowCount:self.topics.count)

        return self.topics.count
    }
    func showUserPage(userId:Int) {
        let vc = UserPageViewController()
        vc.UserId = userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let topic = self.topics[indexPath.row]
        if topic["is_top"].bool == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("topic_top") as! TopicTopCell
            cell.model = topic
            return cell
        }
        
        var cell:TopicBoardBasicCell
        
        if topic["pics_url"].count ==  0 {
            cell = tableView.dequeueReusableCellWithIdentifier("topic") as! TopicCell
        } else if topic["pics_url"].count == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("topic_image_one") as! TopicImageOneCell
        } else if topic["pics_url"].count == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("topic_image_two") as! TopicImageTwoCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("topic_image_three") as! TopicImageThreeCell
        }
        cell.showUserComplete = { userId in
            self.showUserPage(userId)
        }
        cell.data = topic
        cell.pics = topic["pics_url"]
        cell.separatorInset = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let topic = topics[indexPath.row]
    
        let vc = TopicViewController()
        vc.TopicId = topic["_id"].int!

        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}



