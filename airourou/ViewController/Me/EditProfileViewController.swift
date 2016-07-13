//
//  EditProfileViewController.swift
//  爱肉肉
//
//  Created by isno on 16/2/13.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import SwiftyJSON
import SDWebImage
import SwiftHTTP
import SVProgressHUD


class EditProfileViewController:FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "资料设置"
        
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
        
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        
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
            }.cellUpdate({ (cell, row) -> () in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#555")
                })

            
          
        +++ Section()
            <<< TextRow("signature") {
                    $0.title = "个性签名"
                }
               .cellUpdate({ (cell, row) -> () in
                    cell.textField.placeholder = "18个字以内"
                })
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: #selector(EditProfileViewController.save))
    }
    @objc private func save() {
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
        
        
        
        uploader.addFile(UpYunFile(data: UIImageJPEGRepresentation(image, 0.6)!, withPath: filePath))
        var gender = 0
        if data["gender"] as! String == "男生" {
            gender = 1
        }
        
        let signature = data["signature"] as! String
        
       
        let location = (self.form.rowByTag("location")?.baseCell.detailTextLabel?.text)! as String
        
        if location == "请选择地区" {
            SVProgressHUD.showErrorWithStatus("请选择地区")
            return
        }
        

        uploader.uploadComplete = {

            do {
                let params:Dictionary<String,AnyObject> = [
                    "avatar_path":filePath,
                    "nickname":nickname,
                    "gender":gender,
                    "location":location,
                    "signature":signature
                ]
                let opt = try HTTP.POST(UIConstant.AppDomain+"setting/profile", parameters: params)
                
                opt.start { response in
                    dispatch_sync(dispatch_get_main_queue()) {
                    if response.error == nil {
                        let json = JSON(data:response.data)
                        if json["error_code"].int == 0 {
                            SVProgressHUD.showSuccessWithStatus("保存成功")
                        }
                    } else {
                        SVProgressHUD.showErrorWithStatus("服务器请求失败")
                    }
                    }
                }
            } catch {
                SVProgressHUD.showErrorWithStatus("服务器请求失败")
            }
        }
        SVProgressHUD.show()
        uploader.startUpload()
        
    }

    func reloadData() {
        SVProgressHUD.show()
        let opt = try! HTTP.GET(UIConstant.AppDomain+"profile")
        opt.start { response in
            SVProgressHUD.dismiss()
            if response.error == nil {
                let json = JSON(data:response.data)
                if json["error_code"].int == 0 {
                   
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.form.rowByTag("nickname")?.baseValue = json["nickname"].string
                        self.form.rowByTag("nickname")?.updateCell()
                        
                        let imageView  = UIImageView()
                        imageView.ar_setImageWithURL(json["avatar_url"].string!)
                        self.form.rowByTag("avatar")?.baseValue = imageView.image
                        self.form.rowByTag("avatar")?.updateCell()
                    
                    
                    if json["gender"].int == 0 {
                        self.form.rowByTag("gender")?.baseValue = "女生"
                    } else {
                        self.form.rowByTag("gender")?.baseValue = "男生"
                    }
                    self.form.rowByTag("gender")?.updateCell()
 
                    self.form.rowByTag("signature")?.baseValue = json["signature"].string
                    self.form.rowByTag("signature")?.updateCell()

                    self.form.rowByTag("location")?.baseCell.detailTextLabel?.text = json["location"].string
                    //self.form.rowByTag("location")?.updateCell()
                        
                        
                    }
                }
            } else {
                SVProgressHUD.showErrorWithStatus("服务器请求失败")
            }
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
