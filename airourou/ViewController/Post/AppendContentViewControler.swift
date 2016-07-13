//
//  AppendContentViewControler.swift
//  爱肉肉
//
//  Created by isno on 16/2/23.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

import DKImagePickerController
import Eureka
import SwiftyJSON
import SVProgressHUD
import SwiftHTTP
import ReachabilitySwift

class  AppendContentViewController:FormViewController {
    
    private var imagesPreviewView:DKPreviewView!
    
    var Complete:(() -> Void)?
    
    var TopicId:Int = 0 {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "帖子内容增添"
        self.view.backgroundColor = UIColor.whiteColor()
        
        tableView!.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView?.layer.borderColor = UIColor.whiteColor().CGColor
        tableView?.sectionIndexBackgroundColor  = UIColor.whiteColor()
        tableView?.backgroundColor = UIColor.whiteColor()
        
        tableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        })
        
        form +++ Section()
            <<< TextAreaRow("content") { $0.placeholder = "追加的内容" }.cellSetup { cell, row in
                
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
        
        let  postButton = UIBarButtonItem(title: "发布", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AppendContentViewController.postPress))
        self.navigationItem.rightBarButtonItem = postButton
        
    }
    func  postPress() {
        let data =  self.form.values()
        guard let content = data["content"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写增添的内容")
            return
        }
        
        let uploader = UpYunHelper.sharedInstance
        var picsPath:[String] = []
        let assets = self.imagesPreviewView.assets
        
        // 判断网络状态，上传相应质量的图片
        let reachability = try! Reachability.reachabilityForInternetConnection()

        for asset in assets {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "/yyyy/M/dd/mmss"
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
            let params:Dictionary<String,AnyObject>  = [
                "topic_id":self.TopicId,
                "content":content,
                "pics_path_tmp":picsPath.joinWithSeparator("|"),
            ]
            let opt = try! HTTP.POST(UIConstant.AppDomain+"topic/append", parameters: params)
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data:response.data)
                    dispatch_sync(dispatch_get_main_queue()) {
                        if(json["error_code"].int == 0) {
                            SVProgressHUD.showSuccessWithStatus("恭喜，追加内容成功")
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            SVProgressHUD.showErrorWithStatus(json["message"].string!)
                        }
                    }
                }
                
            }
        }
        SVProgressHUD.showWithStatus("内容追加中...")
        uploader.startUpload()
        
        
    }

}