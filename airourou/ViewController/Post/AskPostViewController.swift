//
//  AskPostViewController.swift
//  爱肉肉
//
//  Created by isno on 16/2/10.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import MapKit
import SVProgressHUD
import DKImagePickerController
import SwiftyJSON
import SwiftHTTP

import ReachabilitySwift

class AskPostViewController:FormViewController {
    private var imagesPreviewView:DKPreviewView!
    private var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var name = ""
    private var address = ""
    
    private var coinOptions = ["0个肉票","1个肉票","2个肉票", "3个肉票", "4个肉票", "5个肉票"]
    
    var BoardId = 0
    
    private var currentCoin = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "发布提问"

        tableView!.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView?.layer.borderColor = UIColor.whiteColor().CGColor
        tableView?.sectionIndexBackgroundColor  = UIColor.whiteColor()
        tableView?.backgroundColor = UIColor.whiteColor()

        form +++ Section()
            <<< TextRow("title"){
                $0.placeholder = "请输入提问标题"
                }.cellUpdate({ (cell, row) -> () in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#555")
                })
            <<< TextAreaRow("content") { $0.placeholder = "请输入提问内容" }.cellSetup { cell, row in
               
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
            +++ Section()
            <<< PushRow<String>("coin") {
                $0.title = "悬赏肉票"
                $0.selectorTitle = "请选择肉票"
        
                $0.options = self.coinOptions
                $0.value = "1个肉票"
                }
                .onPresent{ _, to in
                    to.view.tintColor = UIColor(rgba: "#676767")
                }.cellSetup { cell, row in
                    cell.height = {50}
                    
                    
                }.cellUpdate{ cell, row in
                    cell.textLabel?.font = UIFont.systemFontOfSize(16)
                    cell.textLabel?.textColor = UIColor(rgba: "#333")
                }
        
        
        tableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(-35)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        })
        
        
        
        let  postButton = UIBarButtonItem(title: "发布", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AskPostViewController.postPress))
        self.navigationItem.rightBarButtonItem = postButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(AskPostViewController.backBtnClick))
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
        guard let coinString = data["coin"] as? String else {
            SVProgressHUD.showErrorWithStatus("肉票选择错误")
            return
        }
        var coinValue = 0
        var coinValues = [0, 1, 2, 3, 4, 5]
        for (k,v) in self.coinOptions.enumerate() {
            if v == coinString {
                coinValue = coinValues[k]
                break
            }
        }
        if  self.currentCoin < coinValue {
            SVProgressHUD.showErrorWithStatus("抱歉，你的肉票不足")
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
                "board_id":self.BoardId,
                "type":"ask",
                "title":title,
                "coin":coinValue,
                "content":content,
                "pics_path_tmp":picsPath.joinWithSeparator("|"),
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let opt = try! HTTP.GET(UIConstant.AppDomain+"profile")
        opt.start { response in
            dispatch_sync(dispatch_get_main_queue()) {
                let json = JSON(data:response.data)
                self.currentCoin = json["money"].int!
            }
            
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}