//
//  InitViewController.swift
//  爱肉肉
//
//  Created by isno on 16/1/5.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import SDWebImage
import SwiftyJSON
import SwiftHTTP
import Eureka

class InitViewController:FormViewController {
    
    override func viewDidLoad() {
        
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: UITableViewStyle.Plain)
            tableView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleHeight)
        }
        
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "完善个人资料"
        
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 35
            cell.accessoryView?.frame = CGRectMake(0, 0, 70, 70)
            
            cell.textLabel?.font = UIFont.systemFontOfSize(16)
            cell.textLabel?.textColor = UIColor(rgba: "#555")
        }
        TextRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont.systemFontOfSize(16)
            cell.textLabel?.textColor = UIColor(rgba: "#555")
        }
        tableView?.scrollEnabled = false
        tableView!.backgroundColor  = UIConstant.AppBackgroundColor
        tableView!.translatesAutoresizingMaskIntoConstraints = false
        tableView!.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView!.layer.borderColor = UIColor.whiteColor().CGColor
        tableView!.sectionIndexBackgroundColor  = UIColor.whiteColor()
        
        form +++ Section()
            <<< ImageRow("avatar"){
                $0.title = "头像"
                }.cellSetup({ (cell, row) -> () in
                    cell.height = {90}
                    row.value = UIImage(named: "defaultAvatar")
                })
            <<< TextRow("nickname") {
                $0.title = "昵称"
                $0.placeholder = "必填(2~10个字符)"
            }
            
            <<< PushRow<String>("gender") {
                $0.title = "性别"
                $0.selectorTitle = "请选择性别"
                
                $0.options = ["男生", "女生"]
                $0.value = "女生"
                }
                .cellUpdate({ (cell, row) -> () in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#555")
                })
            
            <<< MultiPickerRow<MultiData>("location") { row  in
                row.title = "地区"
                
                var listData: NSDictionary = NSDictionary()
                let filePath = NSBundle.mainBundle().pathForResource("cityData", ofType:"plist" )
                listData = NSDictionary(contentsOfFile: filePath!)!
                
          
                var provices = [MultiData]()
                for _key in listData.allKeys {
                    let province = MultiData(fatherName:"", name: _key as! String)
                    provices.append(province)
                    let citys = listData[_key as! String] as? NSArray
                    if citys != nil {
                        for city in citys! {
                             province.addSub(MultiData(fatherName: _key as! String, name: city as! String))
                        }
                    }
                }
                
                row.options =  provices
                row.value = MultiData(fatherName: "", name: "请选择地区")
        } .cellUpdate({ (cell, row) -> () in
    cell.textLabel?.font = UIFont.systemFontOfSize(16)
    cell.textLabel?.textColor = UIColor(rgba: "#555")
    })
        
        tableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(250)
            
        })
        
        let quickButton = UIButton(type: .Custom)
        quickButton.setTitle("提交注册", forState: .Normal)
        quickButton.setTitleColor(UIColor(rgba: "#fff"), forState: .Normal)
        quickButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        quickButton.backgroundColor = UIColor(rgba: "#6c9f00")
        quickButton.layer.borderColor = UIColor(rgba: "#669503").CGColor
        quickButton.layer.borderWidth = 1.0
        quickButton.layer.cornerRadius = 6
        quickButton.clipsToBounds = true
        quickButton.addTarget(self, action:#selector(InitViewController.singup), forControlEvents: .TouchUpInside)
        self.view.addSubview(quickButton)
        
        quickButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(16)
            make.height.equalTo(46)
            make.right.equalTo(-16)
            make.top.equalTo(tableView!.snp_bottom).offset(8)
        }

        
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated:true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    func singup() {
        
        let data = self.form.values()
        guard let nickname = data["nickname"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写昵称")
            return
        }
        
        let image = data["avatar"] as! UIImage
        let uploader = UpYunHelper.sharedInstance
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "/yyyy/M/dd/mmss"
        let basePath = dateFormatter.stringFromDate(NSDate())
        let filePath = "/uploads"+basePath+".jpg"
        
        
        
        let location = (self.form.rowByTag("location")?.baseCell.detailTextLabel?.text)! as String
        
        if location == "请选择地区" {
            SVProgressHUD.showErrorWithStatus("请选择地区")
            return
        }
        
        uploader.addFile(UpYunFile(data: UIImageJPEGRepresentation(image, 0.6)!, withPath: filePath))
        var gender = 0
        if data["gender"] as! String == "男生" {
            gender = 1
        }
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "YYYY-MM-dd"
        
        
        uploader.uploadComplete = {
            let params:Dictionary<String,AnyObject> = [
                "avatar_path":filePath,
                "nickname":nickname,
                "gender":gender,
                "location":location
            ]
                
            let opt = try! HTTP.POST(UIConstant.AppDomain+"auth/init", parameters: params)
            opt.start { response in
                dispatch_sync(dispatch_get_main_queue(), {
                    let json = JSON(data:response.data)
                    if json["error_code"].int == 0 {
                        SVProgressHUD.showSuccessWithStatus("恭喜，欢迎加入爱肉肉社区!")
                        /** 聊天登录 */
                        NSOperationQueue().addOperationWithBlock({ () -> Void in
                            RCIM.sharedRCIM().connectWithToken(json["rong_token"].string,
                                success: { (userId) -> Void in
                                    let nickname = json["nickname"].string
                                    let avatarUrl = json["avatar_url"].string!
                                    let userInfo = RCUserInfo(userId: userId, name: nickname, portrait: avatarUrl)
                                    RCIM.sharedRCIM().currentUserInfo = userInfo
                                    print("登陆成功。当前登录的用户ID：\(userId)")
                                }, error: { (status) -> Void in
                                    print("登陆的错误码为:\(status.rawValue)")
                                }, tokenIncorrect: {
                                    print("token错误")
                            })
                        })
                        /** 聊天登录 end */
                        
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    } else {
                        SVProgressHUD.showErrorWithStatus(json["message"].string)
                    }
                })
                
            }
        }
        
        SVProgressHUD.show()
        uploader.startUpload()
    }
}

