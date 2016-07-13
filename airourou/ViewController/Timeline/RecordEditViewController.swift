//
//  RecordEditViewController.swift
//  爱肉肉
//
//  Created by isno on 16/4/12.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import SwiftHTTP
import SwiftyJSON
import SVProgressHUD

class RecordEditViewController:FormViewController {
    
    var RecordId = 0
    
    override func viewDidLoad() {
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: UITableViewStyle.Plain)
            tableView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleHeight)
        }
        
        super.viewDidLoad()
        self.title = "修改信息"
        self.view.backgroundColor = UIColor.whiteColor()
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 8
            cell.accessoryView?.frame = CGRectMake(0, 0, 70, 70)
        }
        
        tableView?.backgroundColor  = UIColor.whiteColor()
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView!.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView?.layer.borderColor = UIColor.whiteColor().CGColor
        tableView?.scrollEnabled = false
        tableView?.sectionIndexBackgroundColor  = UIColor.whiteColor()
        form +++ Section() { section in
            section.header = .None
            }
            <<< ImageRow("image") {
                $0.title = "图片"
                }.cellSetup({ (cell, row) -> () in
                    cell.height = {90}
                    row.value = UIImage(named: "image_placehoder.png")
                })
            <<< TextRow("name"){
                $0.title = "名称"
                }.cellUpdate({ (cell, row) in
                    cell.textField.font = UIFont.systemFontOfSize(16)
                    cell.textField.placeholder = "给新养的肉肉起一个名称"
                })
            <<< DateRow("plant_date"){
                $0.title = "种植日期"
                //$0.value =  NSDate()
                //$0.maximumDate = NSDate()
                
                }.cellUpdate({ (cell, row) -> () in
                    cell.selectionStyle = .None
                    
                })
            <<< wikiRow("wiki") {
                $0.title = "关联百科"
                $0.value = WikiData()
        }
        
        // 设置发布按钮
        let addButton = UIBarButtonItem(title:"保存", style: .Plain, target: self, action: #selector(RecordEditViewController.saveData))
        
        self.navigationItem.rightBarButtonItem = addButton
        
    }
    
    func reloadData() {
        SVProgressHUD.show()
        let opt = try! HTTP.GET(UIConstant.AppDomain+"record/update", parameters: ["id":self.RecordId])
        opt.start { response in
            SVProgressHUD.dismiss()
            if response.error == nil {
                let json = JSON(data:response.data)
                if json["error_code"].int == 0 {
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.form.rowByTag("name")?.baseValue = json["record"]["title"].string!
                        self.form.rowByTag("name")?.updateCell()
                        
                        let dformatter = NSDateFormatter()
                        dformatter.dateFormat = "yyyy-MM-dd"
                        let date = dformatter.dateFromString(json["record"]["plant_date"].string!)
                        self.form.rowByTag("plant_date")?.baseValue = date
                        self.form.rowByTag("plant_date")?.updateCell()
          
                        let wiki = WikiData()
                        wiki.id = json["record"]["baike"]["id"].int!
                        wiki.name = json["record"]["baike"]["name"].string!
                        self.form.rowByTag("wiki")?.baseValue = wiki
                        self.form.rowByTag("wiki")?.updateCell()
                        
                        let img = UIImageView()
                        img.ar_setImageWithURL(json["record"]["pic_url"].string!)
                        self.form.rowByTag("image")?.baseValue = img.image
                        self.form.rowByTag("image")?.updateCell()
                    }
                    
                }
            }
            
        }

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func saveData() {
        let data =  self.form.values()
        guard let _ = data["name"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写肉肉名称")
            return
        }
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "YYYY-MM-dd"
        let plantData = dateFormat.stringFromDate(data["plant_date"] as! NSDate)
        
        let wiki = data["wiki"] as! WikiData
        
        let image = data["image"] as! UIImage
        let uploader = UpYunHelper.sharedInstance
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "/yyyy/M/dd/mmss"
        let basePath = dateFormatter.stringFromDate(NSDate())
        let filePath = "/uploads"+basePath+".jpg"
        
        uploader.addFile(UpYunFile(data: UIImageJPEGRepresentation(image, 0.6)!, withPath: filePath))
        
        let params:Dictionary<String,AnyObject> = [
            "title":data["name"] as! String,
            "plant_date":plantData,
            "baike_id":wiki.id,
            "pic_path":filePath,
            "id":self.RecordId
            ]
        uploader.uploadComplete = {
            let opt = try! HTTP.POST(UIConstant.AppDomain+"record/update", parameters: params)
            opt.start { response in
                if response.error == nil {
                    dispatch_sync(dispatch_get_main_queue()) {
                        let json = JSON(data:response.data)
                        if json["error_code"].int == 0 {
                            SVProgressHUD.showSuccessWithStatus(json["message"].string!)
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            SVProgressHUD.showErrorWithStatus(json["message"].string!)
                        }
                    }
                } else {
                    SVProgressHUD.showErrorWithStatus("服务器请求错误")
                }
            }
        }
        SVProgressHUD.show()
        uploader.startUpload()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}