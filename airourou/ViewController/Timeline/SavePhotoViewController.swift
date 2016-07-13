//
//  SavePhotoViewController.swift
//  airourou
//
//  Created by isno on 16/4/21.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SwiftHTTP
import SwiftyJSON
import SVProgressHUD

class SavePhotoViewController:UIViewController {
    var RecordId = 0
    private var button:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIConstant.FontLightColor
        button.setTitle("生成图片", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        return button
    }()
    
    var webView:WKWebView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "生成图片"
        self.view.backgroundColor = UIConstant.AppBackgroundColor
        
        let addButton = UIBarButtonItem(title: "生成图片", style: .Done, target: self, action: #selector(SavePhotoViewController.savePhoto))
       
        self.navigationItem.rightBarButtonItem = addButton
        
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        
        config.preferences.javaScriptEnabled = true
        webView = WKWebView(frame:CGRectZero, configuration: config)
        webView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(webView)
        webView.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(8)
            make.right.bottom.equalTo(-8)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let opt = try! HTTP.GET(UIConstant.AppDomain+"timeline/topic", parameters: ["record_id":self.RecordId])
        opt.start { response in
            if response.error == nil {
                let json = JSON(data:response.data)
                if json["error_code"].int == 0 {
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.webView.loadHTMLString(json["html_source"].string!, baseURL: NSURL(string: "http://www.airourou.me"))
                    }
                }
            }
            
        }
        
    }
    
    func savePhoto() {
       
    }
    func image(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject)
    {
        if didFinishSavingWithError != nil
        {
            SVProgressHUD.showErrorWithStatus("保存出错")
            return
        }
        SVProgressHUD.showSuccessWithStatus("保存成功")
        
    }

}