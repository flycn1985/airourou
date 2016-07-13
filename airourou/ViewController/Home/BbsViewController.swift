//
//  BbsViewController.swift
//  爱肉肉
//
//  Created by isno on 16/1/25.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

import MJRefresh
import SwiftyJSON
import SwiftHTTP
import SDCycleScrollView
import SVProgressHUD


class BbsViewController:UIViewController {
    
    private var _cycleScrollView:SDCycleScrollView!
    private var cycleScrollView:SDCycleScrollView {
        get{
            if(_cycleScrollView != nil){
                return _cycleScrollView!
            }
            _cycleScrollView = SDCycleScrollView()
            _cycleScrollView.autoScrollTimeInterval = 5
            _cycleScrollView.delegate = self
            _cycleScrollView.frame = CGRectMake(0, 0, AppWidth, 150)
            _cycleScrollView.placeholderImage = UIImage(named: "image_placehoder.png")
            return _cycleScrollView
        }
    }
    
    private var _tableView :UITableView!
    private var tableView:UITableView  {
        get{
            if(_tableView != nil){
                return _tableView!
            }
            _tableView = UITableView()
            _tableView.delegate = self
            _tableView.dataSource = self
            _tableView.rowHeight = 62
            _tableView.separatorColor = UIColor(rgba: "#f1f2f2")
            _tableView.registerClass(BbsCell.self, forCellReuseIdentifier: "bbsBoardCell")
            _tableView.backgroundColor = UIConstant.AppBackgroundColor
            _tableView.tableHeaderView = cycleScrollView
            
            return _tableView
        }
    }
    private var boards:JSON! = []
    private var banners:JSON! = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "多肉论坛"
    
        /** load tableview */
        self.view.addSubview(self.tableView)
        
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        let header = RefreshHeader (refreshingBlock: { () -> Void in
            self.refresh()
        })
       
        header.backgroundColor = UIConstant.AppBackgroundColor
        
        self.tableView.mj_header = header
        self.tableView.mj_header.beginRefreshing()
    }
    /** 上拉刷新 */
    func refresh() {
        let opt = try! HTTP.GET(UIConstant.AppDomain+"home")
        opt.start { response in
            if response.error == nil {
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    self.boards = json["boards"]
                    var  bannerImages = [String]()
                    self.banners = json["banners"]
                    for _banner in self.banners {
                        bannerImages.append(_banner.1["pic_url"].string!)
                    }
                    self.cycleScrollView.imageURLStringsGroup = bannerImages
                    self.tableView.mj_header.endRefreshing()

                    self.tableView.reloadData()
                }
            } else {
                dispatch_sync(dispatch_get_main_queue()) {
                    SVProgressHUD.showErrorWithStatus("网络请求失败")
                    self.tableView.mj_header.endRefreshing()
                }
            }
        }
    }
    /** 自动刷新 */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let opt = try! HTTP.GET(UIConstant.AppDomain+"home")
        opt.start { response in
            if response.error == nil {
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    self.boards = json["boards"]
                    var  bannerImages = [String]()
                    self.banners = json["banners"]
                    for _banner in self.banners {
                        bannerImages.append(_banner.1["pic_url"].string!)
                    }
                    self.cycleScrollView.imageURLStringsGroup = bannerImages
                    self.tableView.reloadData()
                }
            } else {
                dispatch_sync(dispatch_get_main_queue()) {
                    SVProgressHUD.showErrorWithStatus("网络请求失败")
                }
            }
        }

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BbsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.boards.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.boards[section]["sub_boards"].count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.boards[section]["name"].string
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor(rgba: "#a1a1a1")
        headerView.tintColor = UIColor(rgba: "#f8f9fa")
        headerView.textLabel!.font = UIFont.boldSystemFontOfSize(14)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bbsBoardCell") as! BbsCell
        let board = self.boards[indexPath.section]["sub_boards"][indexPath.row]
        cell.model = board
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let board = boards[indexPath.section]["sub_boards"][indexPath.row]
    
        let boardVc = BoardViewController()
        boardVc.BoardId = board["id"].int!
        boardVc.navigationItem.title = board["name"].string
        boardVc.boardType = board["board_type"].string!
        self.navigationController?.pushViewController(boardVc, animated: true)
    }
}

extension BbsViewController:SDCycleScrollViewDelegate {
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int) {
        let banner = self.banners[index]["link"]
        switch banner["type"].string! {
        case "topic":
            let vc = TopicViewController()
            vc.TopicId = banner["id"].int!
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}
