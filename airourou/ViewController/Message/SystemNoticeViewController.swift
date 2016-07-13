//
//  SystemNoticeViewController.swift
//  爱肉肉
//
//  Created by isno on 16/3/14.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

import MJRefresh
import SwiftyJSON
import SwiftHTTP
import SVProgressHUD


class SystemNoticeViewController:UIViewController {
    
    private var rows = [JSON]()
    
    var type:String = "" {
        didSet {
            let params:Dictionary<String,AnyObject>= [
                "type":self.type,
                "last_id":0
            ]
            let opt = try! HTTP.GET(UIConstant.AppDomain+"notices", parameters: params)
            SVProgressHUD.show()
            opt.start { response in
                dispatch_sync(dispatch_get_main_queue()) {
                    SVProgressHUD.dismiss()
                    let json = JSON(data:response.data)
                    self.rows = [JSON]()
                    for _row in json["datas"] {
                        self.rows.append(_row.1)
                    }
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    
    private var tableView:UITableView = {
        let view = UITableView()
        view.backgroundColor = .None
        view.rowHeight = 45
        view.estimatedRowHeight = 44.0
        view.rowHeight = UITableViewAutomaticDimension
        view.sectionFooterHeight = 0.1
        view.separatorStyle = .None
        
        view.registerClass(NoticeReplyCell.self, forCellReuseIdentifier:"notice_reply_cell") // 置顶
      
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        let header = MJRefreshNormalHeader(refreshingBlock: { () -> Void in
            let params:Dictionary<String,AnyObject>= [
                "type":self.type,
                "last_id":0
            ]
            let opt = try! HTTP.GET(UIConstant.AppDomain+"notices", parameters: params)
            opt.start { response in
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    self.rows = [JSON]()
                    for _row in json["datas"] {
                        self.rows.append(_row.1)
                    }
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.reloadData()
                }
                
            }
        })
        
        header.lastUpdatedTimeLabel?.hidden = true
        header.stateLabel?.hidden = true
        
        self.tableView.mj_header = header
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {() -> Void in
            var lastId = 0
            if self.rows.count > 0 {
                lastId = self.rows.last!["_id"].int!
            }
            let params:Dictionary<String,AnyObject>= [
                "type":self.type,
                "last_id":lastId
            ]
            let opt = try! HTTP.GET(UIConstant.AppDomain+"notices", parameters: params)
            opt.start { response in
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    
                    for _row in json["datas"] {
                        self.rows.append(_row.1)
                    }
                    self.tableView.mj_footer.endRefreshing()
                    if json["datas"].count > 0 {
                        self.tableView.reloadData()
                    }
                }
            }
        })
        footer.refreshingTitleHidden = true
        footer.stateLabel?.hidden = true
        
        self.tableView.mj_footer = footer
    }
}

extension SystemNoticeViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.tableView.tableViewDisplayWitMsg("暂时还没有任何通知！", rowCount: self.rows.count)
        return self.rows.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = self.rows[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("notice_reply_cell") as! NoticeBaseCell
        cell.data = data
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let data = self.rows[indexPath.row]
        let vc = TopicViewController()
        vc.TopicId = data["topic_id"].int!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}