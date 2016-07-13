//
//  PostTimeline.swift
//  airourou
//
//  Created by 夏菁 on 15/11/9.
//  Copyright © 2015年 isno. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import SVProgressHUD
import DKImagePickerController
import SwiftyJSON
import ReachabilitySwift
import SwiftHTTP

class TimelineNewViewController: FormViewController {
    private var imagesPreviewView:DKPreviewView!
    // 所属记录id
    var RecordId: Int = 0
    
    
    override func viewDidLoad() {
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: UITableViewStyle.Plain)
            tableView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleHeight)
        }
        super.viewDidLoad()
        self.title = "新增时光点"
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        
        tableView?.backgroundColor  = UIColor.whiteColor()
        tableView!.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView?.layer.borderColor = UIColor.whiteColor().CGColor
        tableView?.scrollEnabled = true
        tableView?.sectionIndexBackgroundColor  = UIColor.whiteColor()
        tableView?.tableFooterView = UIView()
        
        form +++ Section()
            <<< TextAreaRow("content") { $0.placeholder = "记录一段美妙的时光吧！" }.cellSetup { cell, row in
                
            }
            <<< BaseRow("images").cellSetup { cell, row in
                
                self.imagesPreviewView = DKPreviewView()
                
                self.imagesPreviewView.showPickerCallback = {
                    let vc = DKImagePickerController()
                    vc.maxSelectableCount = 9
                    vc.defaultSelectedAssets = self.imagesPreviewView.assets
                    
                    vc.didSelectAssets = { (assets: [DKAsset]) in
                        self.imagesPreviewView.replaceAssets(assets)
                    }
                    self.presentViewController(vc, animated: true) {}
                }
                self.imagesPreviewView.alwaysBounceHorizontal = true
                
                self.imagesPreviewView.scrollEnabled = true
                self.imagesPreviewView.backgroundColor = UIColor.whiteColor()
                
                self.imagesPreviewView.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(self.imagesPreviewView)
                
                self.imagesPreviewView.snp_makeConstraints { (make) -> Void in
                    make.right.equalTo(-8)
                    make.height.equalTo(90)
                    make.left.top.equalTo(8)
                }
            }
            <<< DateRow("plant_date"){
                    $0.value = NSDate()
                }.cellUpdate({ (cell, row) -> () in
                cell.textLabel?.text = "时光点"

                
                })
        let  postButton = UIBarButtonItem(title: "发布", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TimelineNewViewController.postPress))
        self.navigationItem.rightBarButtonItem = postButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(TimelineNewViewController.backBtnClick))

    }
    
    func backBtnClick() {
        let data =  self.form.values()
        guard let _ = data["content"] as? String else {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        let vc = UIAlertController(title: "确认取消发布操作么?", message: nil, preferredStyle:.ActionSheet)
        let action = UIAlertAction(title: "确认", style: .Destructive) { (action) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        let cancel = UIAlertAction(title: "取消", style: .Cancel) {   action  in     }
        
        vc.addAction(cancel)
        vc.addAction(action)
        
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    // 发帖
    func  postPress() {
        let data =  self.form.values()
        
        let date = data["plant_date"] as? NSDate
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // Date 转 String
        let plant_date = dateFormatter.stringFromDate(date!)

        guard let content = data["content"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写内容")
            return
        }
        
        // 判断网络状态，上传相应质量的图片
        let reachability = try! Reachability.reachabilityForInternetConnection()
        
        let uploader = UpYunHelper.sharedInstance
        var picsPath:[String] = []
        let assets = self.imagesPreviewView.assets
        for asset in assets {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "/yyyy/MM/dd/mmss"
            let basePath = dateFormatter.stringFromDate(NSDate())
            let randNum = Int(arc4random_uniform(100))+1
            
            asset.fetchFullScreenImage(true, completeBlock: { (image, info) -> Void in
                let width = Int(image!.size.width)
                let height = Int(image!.size.height)
                
                let filePath = "/uploads"+basePath+String(randNum)+"-wh-\(width)-\(height).jpg"
                
                var data:NSData
                if reachability.isReachableViaWiFi() == true {
                    data = image!.mediumQualityJPEGNSData
                } else {
                    data = image!.lowQualityJPEGNSData
                }
                picsPath.append(filePath)
                uploader.addFile(UpYunFile(data: data, withPath: filePath))
            })
            
        }
        uploader.uploadComplete = {
            let params: Dictionary<String,AnyObject>  = [
                "record_id": self.RecordId,
                "content": content,
                "pics_path_tmp":picsPath.joinWithSeparator("|"),
                "plant_date":plant_date
            ]
            let opt = try! HTTP.POST(UIConstant.AppDomain+"timeline/statuses/new", parameters: params)
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data:response.data)
                    dispatch_sync(dispatch_get_main_queue()) {
                        if json["error_code"].int == 0 {
                            SVProgressHUD.showSuccessWithStatus(json["message"].string)
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            SVProgressHUD.showErrorWithStatus(json["message"].string)
                        }
                    }
                }
            }
        }
        SVProgressHUD.showWithStatus("时光点发布中...")
        uploader.startUpload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



