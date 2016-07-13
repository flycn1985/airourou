//
//  UserPageViewController.swift
//  爱肉肉
//
//  Created by isno on 16/1/18.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

import MJRefresh
import SwiftyJSON

import SVProgressHUD
import SwiftHTTP
import SwiftHTTP

let TopHeadViewHeight:CGFloat = 340

class UserPageViewController:UIViewController {
    // 相册view
    private lazy var pickVC: UIImagePickerController = {
        let pickVC = UIImagePickerController()
        pickVC.delegate = self
        pickVC.allowsEditing = true
        return pickVC
    }()
    
    private var topics = [JSON]()
    // 用户头部
    private var headView:UserHeadView = {
        return UserHeadView()
    }()
    
    private var tableView:UITableView = {
        let view = UITableView()
        view.backgroundColor = .None
        view.rowHeight = 45
        view.estimatedRowHeight = 44.0
        view.rowHeight = UITableViewAutomaticDimension
        view.sectionFooterHeight = 0.1
        view.separatorStyle = .None
        
        view.registerClass(TopicCell.self, forCellReuseIdentifier:"topic") // 置顶
        view.registerClass(TopicImageOneCell.self, forCellReuseIdentifier:   "topic_image_one")
        view.registerClass(TopicImageTwoCell.self, forCellReuseIdentifier:   "topic_image_two")
        view.registerClass(TopicImageThreeCell.self, forCellReuseIdentifier: "topic_image_three")
        return view
    }()

    var UserId:Int = 0 {
        didSet {
            loadingView.hidden = false
            self.loadData(self.UserId) {
                
                self.tableView.reloadData()
                self.loadingView.hidden = true
            }
        }
    }

    private var loadingView =  LoadingView()
    
    private lazy var topImageView: UIImageView = {
        let image = UIImageView(frame: CGRectMake(0, 0, AppWidth, TopHeadViewHeight))
        image.contentMode = UIViewContentMode.ScaleToFill
        image.image = UIImage(named: "image_placehoder.png")
        image.alpha = 0.75
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        self.view.addSubview(topImageView)
        
        self.setupTable()
        
        headView.chatButton.addTarget(self, action: #selector(UserPageViewController.chatBtnClicked), forControlEvents: .TouchUpInside)
        headView.followButton.addTarget(self, action: #selector(UserPageViewController.followBtnClicked), forControlEvents: .TouchUpInside)
        
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(UserPageViewController.backBtnClicked))
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "icon_more"), style: .Plain, target: self, action: #selector(UserPageViewController.optClicked))
        
        self.view.addSubview(loadingView)
        loadingView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
 
    }
    @objc private func backBtnClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    /** 聊天 **/
    @objc func chatBtnClicked() {
        if AuthHelper.sharedInstance.isLogin() == false {
            self.navigationController?.pushViewController(LoginViewController(), animated: true)
            return
        }
        let vc = MessageItemViewController()
        vc.conversationType = RCConversationType.ConversationType_PRIVATE
        vc.targetId = String(self.UserId)
        vc.title = "与 " + self.headView.nickname.text!+" 私聊中"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /** 关注 */
    func followBtnClicked() {
        if AuthHelper.sharedInstance.isLogin() == false {
            SVProgressHUD.showErrorWithStatus("抱歉， 你还未登录，无法关注用户!")
            return
        }
        let opt = try! HTTP.POST(UIConstant.AppDomain+"follow", parameters: ["user_id":self.UserId])
        opt.start { response in
            dispatch_sync(dispatch_get_main_queue()) {
                let json = JSON(data:response.data)
                if json["error_code"].int == 0 {
                    SVProgressHUD.showSuccessWithStatus("操作成功")
                    self.headView.followButton.selected = !self.headView.followButton.selected
                } else {
                    SVProgressHUD.showErrorWithStatus(json["message"].string)
                }

            }
            
        }
      
    }
    // operaction
    @objc private func optClicked() {
        
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        let reportAction = UIAlertAction(title: "举报", style:.Default) { _ in
            let vc = UIAlertController(title:nil, message: "请选择类型", preferredStyle: .ActionSheet)
            
            vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            let types = ["垃圾广告", "暴力色情", "人身攻击", "其他"]
            for _var in types {
                let ac = UIAlertAction(title:_var, style:.Default) { action in
                    let opt = try! HTTP.POST(UIConstant.AppDomain+"user/report", parameters: ["user_id":self.UserId])
                    opt.start { _ in
                        dispatch_sync(dispatch_get_main_queue()) {
                            SVProgressHUD.showSuccessWithStatus("举报成功")
                        }
                    }
                    
                }
                vc.addAction(ac)
            }
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        let changeBgAction = UIAlertAction(title: "修改背景", style:.Default) { _ in
            let vc = UIAlertController(title: nil, message: "修改背景", preferredStyle: .ActionSheet)
            
            vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            vc.addAction(UIAlertAction(title: "拍照", style: .Destructive, handler: {  _ in
                self.openCamera()
            }))
            vc.addAction(UIAlertAction(title: "从相册中选择", style: .Default, handler: { _ in
                self.openUserPhotoLibrary()
            }))
            
            self.presentViewController(vc, animated: true, completion: nil)
            
        }

        if AuthHelper.sharedInstance.isLogin() {
            if AuthHelper.sharedInstance.getUid() == self.UserId {
                vc.addAction(changeBgAction)
            } else {
                vc.addAction(reportAction)
            }
        } else {
            vc.addAction(reportAction)
        }
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func loadData(userId:Int, complete:(() -> Void)?) {
        let opt = try! HTTP.GET(UIConstant.AppDomain+"user/\(userId)/topics")
        opt.start { response in
            dispatch_sync(dispatch_get_main_queue(), {
                let json = JSON(data:response.data)
                
                self.topImageView.sd_setImageWithURL(NSURL(string: json["user"]["head_image_url"].string!))
                self.headView.avatarView.sd_setImageWithURL(NSURL(string:json["user"]["avatar_url"].string!))
                self.headView.nickname.text = json["user"]["nickname"].string
                
                self.headView.money.text = String(json["user"]["money"].int!) + " 肉票"
                self.headView.location.text =  json["user"]["location"].string
                
                self.headView.followButton.selected = json["user"]["is_follow"].bool!
                if json["user"]["level"].int > 0 {
                    self.headView.levelIconView.image = UIImage(named: "level\(json["user"]["level"].int!).png")
                }
                self.topics = [JSON]()
                
                for _topic in json["topics"] {
                    self.topics.append(_topic.1)
                }
                if complete != nil {
                    complete!()
                }

            })
            
        }
       
    }
    /** uitableview */
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        headView.frame = CGRectMake(0, 0, AppWidth, TopHeadViewHeight)
        tableView.tableHeaderView = headView
        
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        let header = MJRefreshNormalHeader(refreshingBlock: { () -> Void in
            self.loadData(self.UserId) {
                self.tableView.mj_header.endRefreshing()
                self.tableView.reloadData()

            }
        })
        
        header.lastUpdatedTimeLabel?.hidden = true
        header.stateLabel?.hidden = true
        
        self.tableView.mj_header = header
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {() -> Void in
            
            var lastId = 0
            if self.topics.count > 0 {
                lastId = self.topics.last!["_id"].int!
            }
            let opt = try! HTTP.GET(UIConstant.AppDomain+"user/\(self.UserId)/topics", parameters: ["last_id":lastId])
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data:response.data)
                    dispatch_sync(dispatch_get_main_queue(), {
                        self.tableView.mj_footer.endRefreshing()
                        if json["topics"].count > 0 {
                            for topic in json["topics"] {
                                self.topics.append(topic.1)
                            }
                            self.tableView.reloadData()
                            
                        }
                    })
                    
                }
                
            }
        })
        footer.refreshingTitleHidden = true
        footer.automaticallyHidden = true
        footer.stateLabel?.hidden = true
       
        self.tableView.mj_footer = footer
        /** end */
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UserPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = self.topics[indexPath.row]
        if data["pics_url"].count ==  0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("topic") as! TopicCell
            cell.data = data
            return cell
        } else if data["pics_url"].count == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("topic_image_one") as! TopicImageOneCell
            cell.data = data
            cell.pics = data["pics_url"]
            return cell
        } else if data["pics_url"].count == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("topic_image_two") as! TopicImageTwoCell
            cell.data = data
            cell.pics = data["pics_url"]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("topic_image_three") as! TopicImageThreeCell
            cell.data = data
            cell.pics = data["pics_url"]
            return cell
            
        }
    }
    func  tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let topic = self.topics[indexPath.row]
        let vc = TopicViewController()
        vc.TopicId = topic["_id"].int!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UserPageViewController: UIScrollViewDelegate  {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        if offsetY <= 0 {
            topImageView.frame.origin.y = 0
            topImageView.frame.size.height = -offsetY + TopHeadViewHeight
            topImageView.frame.size.width =  -offsetY+AppWidth
            topImageView.frame.origin.x = (offsetY)*0.5
        }
    }
    
}

/** 用户更改 背景 */
extension UserPageViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 打开照相功能
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            pickVC.sourceType = .Camera
            self.presentViewController(pickVC, animated: true, completion: nil)
        } else {
            SVProgressHUD.showErrorWithStatus("摄像头开启失败")
        }
    }
    private func openUserPhotoLibrary() {
        pickVC.sourceType = .PhotoLibrary
        pickVC.allowsEditing = true
        presentViewController(pickVC, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "/yyyy/M/dd/mmss"
            let basePath = dateFormatter.stringFromDate(NSDate())
            let filePath = "/uploads"+basePath+".jpg"
            let uploader = UpYunHelper.sharedInstance
   
            uploader.uploadComplete = {
                let opt = try! HTTP.POST(UIConstant.AppDomain+"setting/header_bg", parameters: ["pic_path":filePath])
                opt.start { response in
                    SVProgressHUD.dismiss()
                    if response.error == nil {
                        let json = JSON(data:response.data)
                        dispatch_sync(dispatch_get_main_queue(), {
                            self.topImageView.ar_setImageWithURL(json["head_image_url"].string!)
                        })
                    }
                }
            }
            let data = UIImageJPEGRepresentation(image, 0.6)
            uploader.addFile(UpYunFile(data: data!, withPath: filePath))
            
            SVProgressHUD.show()
            uploader.startUpload()
            
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        pickVC.dismissViewControllerAnimated(true, completion: nil)
    }
}
