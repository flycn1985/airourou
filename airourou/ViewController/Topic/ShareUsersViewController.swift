//
//  ShareUsersViewController.swift
//  爱肉肉
//
//  Created by isno on 16/2/2.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import SwiftyJSON
import SwiftHTTP
import MJRefresh


class ShareUsersViewController:UIViewController {
    var TopicId:Int! {
        didSet {
            let opt = try! HTTP.GET(UIConstant.AppDomain+"topic/share/users", parameters: ["topic_id":self.TopicId])
            opt.start { response in
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    self.users = [JSON]()
                    for _user in json["users"] {
                        self.users.append(_user.1)
                    }
                    self.tableView.reloadData()
                }
            }
           
        }
    }
    
    var users:[JSON] = [JSON]()
    
    var tableView:UITableView = UITableView()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        self.title = "报名情况"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 62
        self.tableView.separatorColor = UIColor(rgba: "#f1f2f2")
        self.tableView.registerClass(ShareUserCell.self, forCellReuseIdentifier: "share_user_cell")
        self.tableView.backgroundColor = UIConstant.AppBackgroundColor
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        let header = MJRefreshNormalHeader(refreshingBlock: { () -> Void in
            
            
            let opt = try! HTTP.GET(UIConstant.AppDomain+"topic/share/users", parameters: ["topic_id":self.TopicId])
            opt.start { response in
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    self.users = [JSON]()
                    for _user in json["users"] {
                        self.users.append(_user.1)
                    }
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.reloadData()
                }
            }

        })
        header.lastUpdatedTimeLabel?.hidden = false
        header.stateLabel?.hidden = false
        header.backgroundColor = UIConstant.AppBackgroundColor
        
        self.tableView.mj_header = header

    }
    override func  viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ShareUsersViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
  

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("share_user_cell") as! ShareUserCell
        let user = self.users[indexPath.row]
        cell.userAvatarView.sd_setImageWithURL(NSURL(string: user["avatar_url"].string!))
        cell.nickname.text = user["nickname"].string!
        cell.createdAt.text = user["created_at"].string!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = self.users[indexPath.row]
        let vc = UserPageViewController()
        vc.UserId = user["_id"].int!
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

class ShareUserCell:UITableViewCell {
    private var userAvatarView:UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 32/2
        view.clipsToBounds = true
        return view
    }()
    private var nickname:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(16.0)
        label.textColor = UIColor(rgba: "#676767")
        return label
    }()
    
    private var createdAt:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgba: "#bfbfbf")
        label.font = UIFont.systemFontOfSize(12)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        self.setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.userAvatarView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.userAvatarView)
        
        
        self.userAvatarView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(15)
            make.left.equalTo(self.contentView).offset(15)
            make.size.equalTo(32)
        }
        
        self.nickname.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.nickname)
        self.nickname.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.userAvatarView.snp_right).offset(8)
            make.top.equalTo(self.userAvatarView.snp_top)
        }
        
        self.createdAt.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.createdAt)
        self.createdAt.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.userAvatarView.snp_right).offset(8)
            make.top.equalTo(self.nickname.snp_bottom).offset(3)
        }

    }
    
}
