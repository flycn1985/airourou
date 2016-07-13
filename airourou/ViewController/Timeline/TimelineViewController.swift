//
//  TimelineViewController.swift
//  airourou
//
//  Created by 夏菁 on 15/10/24.
//  Copyright © 2015年 isno. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON
import SwiftHTTP

class TimelineViewController: UIViewController {

    // 数据
    var datas:[JSON] = [JSON]()
    // 记录id
    var RecordId: Int!

    
    // 表格
    private var tableView: UITableView!
    
    private var headerView = RecordInfoView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        // 设置发布按钮
        let addButton = UIBarButtonItem(title:nil, style: .Done, target: self, action: #selector(TimelineViewController.showMenu))
        addButton.image = UIImage(named: "icon_more")
        self.navigationItem.rightBarButtonItem = addButton
        
        
        // 设置表格属性
        setupTableView()
        

    }
    func showMenu() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle:.ActionSheet)
        let action = UIAlertAction(title: "新增时光点", style: .Default) { (action) -> Void in
            let vc = TimelineNewViewController()
            vc.RecordId = self.RecordId
           
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let editAction = UIAlertAction(title: "修改信息", style: .Default) { action in
            let vc =  RecordEditViewController()
            vc.RecordId = self.RecordId
            vc.reloadData()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        _ = UIAlertAction(title: "生成图片", style: .Default) { action in
            let vc =  SavePhotoViewController()
            vc.RecordId = self.RecordId
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        let deleteAction = UIAlertAction(title: "删除整个时光", style: .Destructive) { (action) -> Void in
            
            let delVC = UIAlertController(title: "删除整个时光", message: "该操作不可恢复，请确认是否删除?", preferredStyle: .Alert)
            
            let del = UIAlertAction(title: "确定删除", style: .Destructive, handler: { action in
                let opt = try! HTTP.POST(UIConstant.AppDomain+"record/remove", parameters: ["id":self.RecordId])
                opt.start { response in
                    if response.error == nil {
                        let json = JSON(data:response.data)
                        if json["error_code"].int == 0 {
                            dispatch_sync(dispatch_get_main_queue()) {
                                SVProgressHUD.showSuccessWithStatus("删除成功")
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                    }
                    
                }
            })
            
            delVC.addAction(UIAlertAction(title: "取消", style: .Cancel) {   action  in     })
           
            delVC.addAction(del)
            
            self.presentViewController(delVC, animated: true, completion: nil)
        }
        
        
        let cancel = UIAlertAction(title: "取消", style: .Cancel) {   action  in     }
        
        vc.addAction(cancel)
        
        vc.addAction(action)
        //vc.addAction(savePhotoAction)
        
        let share = UIAlertAction(title: "分享至论坛", style: .Default) { (action) -> Void in
            // 获取数据
            let vc = ShareToForumViewController()
            vc.RecordId = self.RecordId
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vc.addAction(share)
        
        
        vc.addAction(editAction)
        vc.addAction(deleteAction)
        
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let opt = try! HTTP.GET(UIConstant.AppDomain+"timeline/record/\(self.RecordId)")
        opt.start { response in
            if response.error == nil {
                let json = JSON(data:response.data)
                if json["error_code"].int == 0 {
                    
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.headerView.imageView.ar_setImageWithURL(json["data"]["pic_url"].string!)
                       
                        self.headerView.plantDate.text = json["data"]["plant_date"].string
                        self.headerView.count.text = "共有\(json["data"]["timelines_count"].int!)篇时光记录"
                        self.title = json["data"]["title"].string
                        
                        self.datas = [JSON]()
                        for _data in json["data"]["timelines"] {
                            self.datas.append(_data.1)
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                    
                } else {
                    SVProgressHUD.showErrorWithStatus(json["message"].string)
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /**
     * 设置表格属性
     *
     */
    func setupTableView() {
        
        tableView = UITableView()
       
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .None
        tableView.estimatedRowHeight = 45
        tableView.separatorStyle = .None
        tableView.registerClass(TimelineCell.self, forCellReuseIdentifier: "timeline_view_cell")
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: AppWidth, height: 150)
        
 
        
        
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.right.left.bottom.equalTo(0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TimelineViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.datas.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timeline_view_cell") as! TimelineCell
        cell.data = self.datas[indexPath.row]
        let data = self.datas[indexPath.row]
        
        cell.deleteComplete = {
            
            let vc = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cancel = UIAlertAction(title: "取消", style: .Cancel) {   action  in     }
            
            vc.addAction(cancel)
            
            
            let del = UIAlertAction(title: "删除", style: .Destructive) { action in
                let opt = try! HTTP.POST(UIConstant.AppDomain+"timeline/statuses/remove", parameters: ["id":data["_id"].int!])
                opt.start { response in
                    if response.error == nil {
                        let json = JSON(data:response.data)
                        if json["error_code"].int == 0 {
                            dispatch_sync(dispatch_get_main_queue(), {
                                SVProgressHUD.showSuccessWithStatus("删除成功")
                                self.datas.removeAtIndex(indexPath.row)
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }
            vc.addAction(del)
            
            self.presentViewController(vc, animated: true, completion: nil)
        }
        cell.forwardComplete = {
            let vc = ShareToForumViewController()
            vc.StatusesId = data["_id"].int!
            self.navigationController?.pushViewController(vc, animated: true)
        }

        return cell
    }
    
}











