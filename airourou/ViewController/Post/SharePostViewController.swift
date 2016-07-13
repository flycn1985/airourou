//
//  SharePostViewController.swift
//  爱肉肉
//
//  Created by isno on 16/1/27.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import MapKit
import SVProgressHUD
import DKImagePickerController
import SwiftyJSON
import ReachabilitySwift
import SwiftHTTP

class SharePostViewController:FormViewController {
    
    private var imagesPreviewView:DKPreviewView!
    private var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    private var name = ""
    private var address = ""
    
    private var numOptions = ["1", "3", "5", "7", "10", "15"]
    private var expressOptions = ["同城自取", "快递", "平邮"]
    
    
    private var farPostage = DecimalRow("far_postage"){
        $0.placeholder = "不超过25元"
        $0.title = "偏远省份邮费"
    }
    private var nearbyPostage = DecimalRow("nearby_postage"){
        $0.placeholder = "不超过15元"
        $0.title = "附近省份邮费"
    }
    
    var BoardId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "分享赠送"
    
        tableView!.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView?.layer.borderColor = UIColor.whiteColor().CGColor
        tableView?.sectionIndexBackgroundColor  = UIColor.whiteColor()
        tableView?.backgroundColor = UIColor.whiteColor()
        
        form +++ Section()
            <<< TextRow("title"){
                $0.placeholder = "请输入标题"
                }.cellUpdate({ (cell, row) -> () in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#555")
                })
            
            <<< TextAreaRow("content") {
                $0.placeholder = "请输入赠送描述内容" }
            .cellSetup { cell, row in
            }
            <<< BaseRow("images").cellSetup { cell, row in
                
                self.imagesPreviewView = DKPreviewView()
                
                self.imagesPreviewView.showPickerCallback = {
                    let vc = DKImagePickerController()
                    vc.maxSelectableCount = 6
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
            <<< BaseRow("location").cellSetup { cell, row in
                cell.height = {50}
                }.cellUpdate{ cell, row in
                    cell.textLabel?.text = "我的位置"
                    cell.textLabel?.textAlignment = .Left
                    cell.imageView?.image = UIImage(named: "icon_location")
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#333")
                    
                }.onCellSelection({ (cell, row) -> () in
                    let vc = MapViewController() { view in
                        row.baseCell.textLabel?.text = view.data["name"].string
                        
                        self.name = view.data["name"].string!
                        self.address = view.data["addr"].string!
                        self.currentLocation = view.currentLocation
                        
                        cell.imageView?.image = UIImage(named: "icon_location_hl")
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                })
            +++ Section("分享详情")
            <<< TextRow("city"){
                $0.placeholder = "请输入如上海,杭州等城市名"
                $0.title = "所在地"
                }.cellUpdate({ (cell, row) -> () in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#333")
                })
            <<< PushRow<String>("num") {
                $0.title = "分享数量"
                $0.selectorTitle = "请选择分享数量"
                
                $0.options = self.numOptions
                $0.value = "1"
                }
                .onPresent{ _, to in
                    to.view.tintColor = UIColor(rgba: "#676767")
                }.cellSetup { cell, row in
                    cell.height = {50}
                }.cellUpdate{ cell, row in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#333")
                }
            <<< PushRow<String>("express") {
                $0.title = "邮寄方式"
                $0.selectorTitle = "请选择邮寄方式"
                
                $0.options = self.expressOptions
                $0.value = "快递"
                }
                .onPresent{ _, to in
                    to.view.tintColor = UIColor(rgba: "#676767")
                }.cellSetup { cell, row in
                    cell.height = {50}
                }.cellUpdate{ cell, row in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#333")
                }
            
            <<< nearbyPostage.cellUpdate({ (cell, row) -> () in
                cell.textLabel?.font = UIFont.systemFontOfSize(16)
                cell.textLabel?.textColor = UIColor(rgba: "#333")
            })
            <<< farPostage.cellUpdate({ (cell, row) -> () in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#333")
                })
        
        
        
        tableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(-35)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        })
        
        
        
        let  postButton = UIBarButtonItem(title: "发布", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SharePostViewController.postPress))
        self.navigationItem.rightBarButtonItem = postButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(SharePostViewController.backBtnClick))
    }
    func backBtnClick() {
        let data =  self.form.values()
        guard let _ = data["content"] as? String else {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        let vc = UIAlertController(title:nil , message: "取消发布操作?", preferredStyle: .ActionSheet)
        let action = UIAlertAction(title: "确定", style: .Destructive) { _ in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        vc.addAction(action)
        vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    @objc private func  postPress() {
        let data =  self.form.values()
        guard let title = data["title"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写标题")
            return
        }
        
        guard let content = data["content"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写内容")
            return
        }

        var numValue = 1
        var numValues = [1,3,5,7,10,15]
        
        guard let numString = data["num"] as? String else {
            SVProgressHUD.showErrorWithStatus("分享数量错误")
            return
        }
        
        for (k,v) in self.numOptions.enumerate() {
            if v == numString {
                numValue = numValues[k]
                break
            }
        }
        
        /** 快递 */
        var expressValue = 1
        var expressValues = [1,2,3]
        guard let expressString = data["express"] as? String else {
            SVProgressHUD.showErrorWithStatus("邮寄方式错误")
            return
        }
        
        for (k,v) in self.expressOptions.enumerate() {
            if v == expressString {
                expressValue = expressValues[k]
                break
            }
        }
        var farPostage:Double = 0.0
        var nearbyPostage:Double = 0.0
        
        if expressValue != 1 {
            let far = data["far_postage"] as? Double
            if far == nil {
                SVProgressHUD.showErrorWithStatus("请填写偏远省份邮费")
                return
            } else {
                farPostage = far!
            }
            
            let neary = data["nearby_postage"] as? Double
            if neary == nil {
                SVProgressHUD.showErrorWithStatus("请填写附近省份邮费")
                return
            } else {
                nearbyPostage = neary!
            }
            
        }
        
        guard let shareCity = data["city"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写分享所在地")
            return
        }


        // 判断网络状态，上传相应质量的图片
        let reachability = try! Reachability.reachabilityForInternetConnection()
        
        let uploader = UpYunHelper.sharedInstance
        var picsPath:[String] = []
        let assets = self.imagesPreviewView.assets
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
            
            let params:Dictionary<String, AnyObject> = [
                "board_id":self.BoardId,
                "type":"share",
                "title":title,
                "content":content,
                "pics_path_tmp":picsPath.joinWithSeparator("|"),
                "share_city":shareCity,
                "share_num":numValue,
                "share_express":expressValue,
                "share_nearby_postage":nearbyPostage,
                "share_far_postage":farPostage,
                "lat":self.currentLocation.latitude,
                "lng":self.currentLocation.longitude,
                "place":self.name,
                "address":self.address
            
            ]
            let opt = try! HTTP.POST(UIConstant.AppDomain+"topic/new", parameters: params)
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data:response.data)
                    dispatch_sync(dispatch_get_main_queue()) {
                        if(json["error_code"].int == 0) {
                            SVProgressHUD.showSuccessWithStatus("恭喜，发表话题成功")
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            SVProgressHUD.showErrorWithStatus(json["message"].string!)
                        }
                    }
                }
                
            }
        }
        SVProgressHUD.showWithStatus("话题发布中...")
        uploader.startUpload()
    }
    override func viewDidAppear(animated: Bool) {
    
        super.viewDidAppear(animated)
           }
    func showNotice() {
        PostNoticeView.sharedInstance.show()
        
        PostNoticeView.sharedInstance.noticeView.tip1.text = "分享前请仔细阅读并确认："
        PostNoticeView.sharedInstance.noticeView.tip2.text = "1.你需要保证交换内容的真实性。如果你的交换被举报并确认有欺骗行为，并使肉友遭到损失，我们有权将你的个人信息提交至相关部门，承担相应的法律责任。"
        PostNoticeView.sharedInstance.noticeView.tip3.text = "2.请按照肉友报名申请纪录来安排分享，如成功申请的花友符合分享条件，没有得到分享，经查实可能会扣除花币。"
        
        
        PostNoticeView.sharedInstance.noticeView.cancelComplete = {
            PostNoticeView.sharedInstance.clearNotice()
            self.navigationController?.popViewControllerAnimated(true)
        }
        PostNoticeView.sharedInstance.noticeView.confirmComplete = {
            PostNoticeView.sharedInstance.clearNotice()
        }

    }
}