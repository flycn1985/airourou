//
//  MeViewController.swift
//  爱肉肉
//
//  Created by isno on 16/1/5.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SVProgressHUD
import SwiftHTTP


class MeViewController:UIViewController {
    var levelIconView:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private var folderSize:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = UIColor(rgba: "#bdbdbd")
        return label
    }()
    private var nickname:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFontOfSize(16)
        label.textColor = UIColor(rgba: "#333")
        return label
    }()
    private var coin:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = UIConstant.FontLightColor
        return label
        
    }()
    private var joinAt:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor(rgba: "#bdbdbd")
         return label
    }()
    private var avatarView:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "defaultAvatar")
        view.layer.borderColor = UIColor(rgba: "#fff").CGColor
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        view.contentMode = .ScaleAspectFill
        view.layer.cornerRadius = 72/2
        return view
    }()
    
    private var logoutButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("退出", forState: .Normal)
        button.setTitleColor(UIColor(rgba: "#fff"), forState: .Normal)
        button.backgroundColor = UIColor(rgba: "#ff3e2b")
        button.layer.borderColor = UIColor(rgba: "#e4412f").CGColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    private var loginView = LoginView()
    private var tableView = UITableView()
    
    override func viewDidLoad() {
        self.title = "我"
        self.view.backgroundColor = UIColor.whiteColor()
        self.setupTable()
        
        loginView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loginView)
        loginView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        loginView.loginCallback = {
            self.navigationController!.pushViewController(LoginViewController(), animated: true)
        }
       
    }
    
    private func setupTable() {
        tableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Grouped)
        tableView.backgroundColor  = UIConstant.AppBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 45
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorInset = UIEdgeInsetsMake(0,0,0,0)
        tableView.separatorColor = UIColor(rgba: "#f1f2f2")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"me_cell") // 置顶
        
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if AuthHelper.sharedInstance.isLogin() == true {
            loginView.hidden = true
            NSOperationQueue().addOperationWithBlock { () -> Void in
                let size = FileTool.folderSize(UIConstant.CachesPath)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.folderSize.text = (NSString(format:"%.1f",size) as String)+"MB"
                })
            }
            
        } else {
            loginView.hidden = false
            return
        }
        let opt = try! HTTP.GET(UIConstant.AppDomain+"profile")
        opt.start { response in
            dispatch_sync(dispatch_get_main_queue()) {
                let json = JSON(data:response.data)
                if json["error_code"].int == 0 {
                    self.nickname.text = json["nickname"].string
                    self.coin.text =  String(json["money"].int!) + "个肉票"
                    self.joinAt.text = json["join_at"].string! + "加入"
                    self.avatarView.ar_setImageWithURL(json["avatar_url"].string!)
                    if json["level"].int > 0 {
                        self.levelIconView.image = UIImage(named: "level\(json["level"].int!).png")
                    }
                }

            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section)
        {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 2
        case 3:
            return 1
        default:
            return 0
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("me_cell")! as UITableViewCell
        cell.accessoryType = .DisclosureIndicator
        if indexPath.section == 0 {
            return userCell()
        }
        if indexPath.section == 1 {
            cell.textLabel!.text = "资料修改"
            cell.textLabel!.font = UIFont.systemFontOfSize(15)
            cell.textLabel?.textColor = UIColor(rgba: "#555")
            cell.imageView!.image = UIImage(named: "icon_profile")
        }
        var name = ""
        var imageUrl = ""
        if indexPath.section == 2 {
            switch(indexPath.row) {
            case 0:
                name = "清除缓存"
                imageUrl = "icon_clear"
                cell.accessoryType = .None
                cell.addSubview(self.folderSize)
                self.folderSize.snp_makeConstraints(closure: { (make) -> Void in
                    make.right.equalTo(-16)
                    make.centerY.equalTo(cell)
                })
                
            case 1:
                name = "关于爱肉肉"
                imageUrl = "icon_about"
                
            default: break
            }
            cell.textLabel!.text = name
            cell.textLabel!.font = UIFont.systemFontOfSize(15)
            cell.imageView!.image = UIImage(named: imageUrl)
            cell.textLabel?.textColor = UIColor(rgba: "#555")
        }
        
        if indexPath.section == 3 {
            cell.backgroundColor = .None
            
            cell.addSubview(logoutButton)
            logoutButton.addTarget(self, action: #selector(MeViewController.logout), forControlEvents: UIControlEvents.TouchUpInside)
            logoutButton.snp_makeConstraints(closure: { (make) -> Void in
                make.top.equalTo(2)
                make.right.equalTo(-12)
                make.left.equalTo(12)
                make.height.equalTo(45)
                make.bottom.equalTo(-2)
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
           let vc = UserPageViewController()
            vc.UserId = AuthHelper.sharedInstance.getUid()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        if indexPath.section == 1 {
            let vc = EditProfileViewController()
            vc.reloadData()
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    
        if indexPath.section == 2 {
            switch(indexPath.row) {
            case 0:
                let vc = UIAlertController(title:nil, message: "您浏览过的图片会缓存到手机，这样下次打开就不会浪费流量。如果您的手机空间较大，建议不必清除缓存!", preferredStyle: .Alert)
                
                let action = UIAlertAction(title: "清除", style: .Destructive) { action in
                    SVProgressHUD.show()
                    FileTool.cleanFolder(UIConstant.CachesPath, complete: { _ in
                        SVProgressHUD.showSuccessWithStatus("清除缓存成功")
                        self.folderSize.text = "0.0 MB"
                    })
                }
                
                vc.addAction(action)
                vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(vc, animated: true, completion: nil)

                
                
                break
            case 0:
                let vc = MessageSettingViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            
            default: break
            }
        }
        
    }
    
    func logout(){
        let vc = UIAlertController(title: nil, message: "确定退出么", preferredStyle: .ActionSheet)
        let action = UIAlertAction(title: "退出", style: .Destructive) { action in
            RCIM.sharedRCIM().logout()
            AuthHelper.sharedInstance.logout()
            self.loginView.hidden = false
        }
        
        vc.addAction(action)
        vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    private func userCell() -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.accessoryType = .DisclosureIndicator
        cell.selectionStyle = .None
        
        cell.addSubview(self.avatarView)
        
        self.avatarView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(72)
            make.top.equalTo(12)
            make.left.equalTo(20)
            make.bottom.equalTo(-12)
        }
        cell.addSubview(self.levelIconView)
        levelIconView.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.width.equalTo(16)
            make.right.equalTo(self.avatarView.snp_right).offset(0)
            make.bottom.equalTo(self.avatarView.snp_bottom).offset(-3)
        }
        
        cell.addSubview(self.nickname)
        
        self.nickname.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatarView.snp_top).offset(8)
            make.left.equalTo(avatarView.snp_right).offset(8)
        }
        
        cell.addSubview(self.coin)
        self.coin.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nickname.snp_bottom).offset(5)
            make.left.equalTo(avatarView.snp_right).offset(8)
        }
        
        cell.addSubview(self.joinAt)
        
        self.joinAt.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(coin.snp_bottom).offset(5)
            make.left.equalTo(avatarView.snp_right).offset(8)
        }
        
        let homePage = UILabel()
        homePage.text = "个人主页"
        homePage.font = UIFont.boldSystemFontOfSize(16)
        homePage.textColor = UIColor(rgba: "#bdbdbd")
        
        cell.addSubview(homePage)
        
        homePage.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(cell)
            make.right.equalTo(-30)
        }
        
        
        return cell
    }
}
