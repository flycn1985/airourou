//
//  TopicHtmlCell.swift
//  爱肉肉
//
//  Created by isno on 16/3/28.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import WebKit

import KVOController

public typealias TopicWebViewContentHeightChanged = (CGFloat) -> Void

class TopicHtmlCell:UITableViewCell,WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate{
    
    
    private weak var _loadView:LoadingView?
    
    private var nav:UIViewController?
    private var data:JSON?
    
    var pics:[String]?
    
    var contentHeight : CGFloat = 0
    
    var webView: WKWebView!

    var contentHeightChanged : TopicWebViewContentHeightChanged?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIColor.whiteColor()
        let config = WKWebViewConfiguration()
        
        config.preferences = WKPreferences()

        config.preferences.javaScriptEnabled = true
        config.userContentController = WKUserContentController()
        config.userContentController.addScriptMessageHandler(self, name: "webViewApp")
        
        webView = WKWebView(frame:self.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.scrollView.scrollEnabled = false
        webView.scrollView.bounces = false
        webView.UIDelegate = self
        self.addSubview(webView)
        webView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.right.left.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        self.KVOController.observe(self.webView!.scrollView, keyPath: "contentSize", options: [.New]) {
            [weak self] (observe, observer, change) -> Void in
            if let weakSelf = self {
                let size = change[NSKeyValueChangeNewKey] as! NSValue
                weakSelf.contentHeight = size.CGSizeValue().height;
                weakSelf.contentHeightChanged?(weakSelf.contentHeight)
            }
        }
        
        pics = [String]()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let data = message.body as! Dictionary<String,AnyObject>

        if (data["method"] as! String == "PreviewImages") {
            let currentIndex = data["currentIndex"] as! Int
            let browser = GJPhotoBrowser()
            browser.dataSource = self
            browser.showWith(currentIndex: currentIndex)
            
            //
            //self.ShowImagesComplete!(currentIndex:currentIndex)
        }
        if(data["method"] as! String == "ShowShareUsers") {
            let topicId = data["topicId"] as! Int
            let vc = ShareUsersViewController()
            vc.TopicId = topicId
            self.nav?.navigationController!.pushViewController(vc, animated: true)
        }
    }
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        //
        let ac = UIAlertController(title: webView.title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: { (a) -> Void in
            completionHandler()
        }))
        self.nav?.presentViewController(ac, animated: true, completion: nil)
        //self.HtmlAlertComplete!(view: ac)
    }
    func bind(data:JSON, pics:JSON, nav:UIViewController) {
        self.nav = nav
        for _pic  in pics {
            self.pics?.append(_pic.1.string!)
        }
        webView.loadHTMLString(data["content"].string!, baseURL: NSURL(string: "http://www.airourou.me"))
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        let ac = UIAlertController(title: webView.title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler:
            { (ac) -> Void in
                completionHandler(true)  //按确定的时候传true
        }))
        
        ac.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler:
            { (ac) -> Void in
                completionHandler(false)  //取消传false
        }))
        self.nav?.presentViewController(ac, animated: true, completion: nil)
         //self.HtmlAlertComplete!(view: ac)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        //self.HtmlComplete!(webView: webView)
    }
    
}
    


extension WKWebView {
    func getDocumentHeight(completion: (CGFloat) -> ()) {
        let javascriptString = "" +
            "var body = document.body;" +
            "var html = document.documentElement;" +
            "Math.max(" +
            "   body.scrollHeight," +
            "   body.offsetHeight," +
            "   html.clientHeight," +
            "   html.offsetHeight" +
        ");"
        evaluateJavaScript(javascriptString) { result, error in
            if let error = error {
                print(error)
                completion(0)
            } else if let result = result, let height = JSON(result).int {
                completion(CGFloat(height))
            } else {
                completion(0)
            }
        }
    }
    func getContent(completion: (String) -> ()) {
        self.evaluateJavaScript("document.getElementById('content').innerHTML") {
            result, error in
            if let str = result as? String {
                completion(str)
            }
        }
    }
}