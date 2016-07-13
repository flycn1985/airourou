//
//  TopicViewController.swift
//  爱肉肉
//
//  Created by isno on 16/3/4.
//  Copyright © 2016年 isno. All rights reserved.
//
import Foundation
import MJRefresh
import SwiftyJSON
import SVProgressHUD
import SwiftHTTP

class TopicViewController:BaseViewController {
    
    private var webViewContentCell:TopicHtmlCell?
    
    var TopicId:Int = 0
    
    private var replyId:Int = 0
    
    var topic:JSON?
    
    /** 回复框 */
    private var keyboardBox = TopicKeyboardView()
    private var keyboardUser = KeyboardUser()
    
    private var _tableView:UITableView!
    private var tableView:UITableView {
        get {
            if _tableView != nil {
                return self._tableView
            }
            _tableView = UITableView()
            _tableView.delegate = self
            _tableView.dataSource = self
            
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            _tableView.estimatedRowHeight = 18
            _tableView.rowHeight = UITableViewAutomaticDimension
            _tableView.backgroundColor = UIConstant.AppBackgroundColor
            
            regClass(_tableView, cell: TopicHeadCell.self)
            regClass(_tableView, cell: TopicHtmlCell.self)
            regClass(_tableView, cell: TopicExtendCell.self)
            regClass(_tableView, cell: TopicReplyCell.self)
            regClass(_tableView, cell: TopicReplyToCell.self)
            
            return _tableView
        }
    }
    
    private var maskView:UIView!
    
    private var replies = [JSON]()
    
    private var htmlHeight:CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(-52)
        }
        let footer = RefreshFooter { () -> Void in
            let params = [
                "topic_id":self.TopicId,
                "last_id":self.replies.count > 0 ?  self.replies.last!["_id"].int! : 0
            ]
            let opt = try! HTTP.GET(UIConstant.AppDomain+"topic/replies",parameters: params)
            opt.start { response in
                if response.error == nil {
                    dispatch_sync(dispatch_get_main_queue()) {
                        let json = JSON(data:response.data)
                        for _json in json["replies"] {
                            self.replies.append(_json.1)
                        }
                        if json["replies"].count > 0 {
                            self.tableView.reloadData()
                        }
                        self.tableView.mj_footer.endRefreshing()
                        
                    }
                }
            }
        }
        tableView.mj_footer = footer
        
        /**
         键盘遮罩
         */
        maskView = UIView()
        maskView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.0)
        maskView.hidden = true
        
        self.view.addSubview(self.maskView)
        self.maskView.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(0)
            make.top.bottom.equalTo(0)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(TopicViewController.hideKeyBoard))
        self.maskView.userInteractionEnabled = true
        self.maskView.addGestureRecognizer(tap)
        
        /** end 遮罩 */
        
        self.setupKeyBoardView()
        
        
        let shareBtn = UIBarButtonItem(image: UIImage(named: "icon_share"), style: .Plain, target: self, action: #selector(TopicViewController.shareClicked))
        let moreBtn = UIBarButtonItem(image: UIImage(named: "icon_more"), style: .Plain, target: self, action: #selector(TopicViewController.moreClicked))
        self.navigationItem.rightBarButtonItems = [moreBtn, shareBtn]
        
        // 载入帖子
        
        let opt = try! HTTP.GET(UIConstant.AppDomain+"topic/view/\(self.TopicId)")
        opt.start { response in
            dispatch_sync(dispatch_get_main_queue()) {
                let json = JSON(data:response.data)
                if json["error_code"].int != 0 {
                    SVProgressHUD.showErrorWithStatus(json["message"].string)
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    self.topic = json["topic"]
                    self.keyboardBox.likeButton.selected = self.topic!["is_like"].bool!
                    self.tableView.reloadData()
                    self.tableView.mj_footer.beginRefreshing()
                }
                
            }
        }
        self.showLoadingView()
    }
    
    func shareClicked() {
        if self.topic == nil {
            return
        }
        if self.topic!["share"]["pic_url"].string != "" {
            UMSocialData.defaultData().urlResource.setResourceType(UMSocialUrlResourceTypeImage, url: self.topic!["share"]["pic_url"].string)
        } else {
            UMSocialData.defaultData().urlResource.setResourceType(UMSocialUrlResourceTypeImage, url: nil)
            
        }
        UMSocialData.defaultData().extConfig.wechatSessionData.title = self.topic!["title"].string
        UMSocialData.defaultData().extConfig.wechatSessionData.url = "http://www.airourou.me/topic/\(self.TopicId)"
        
        UMSocialData.defaultData().extConfig.wechatTimelineData.title = self.topic!["title"].string
        UMSocialData.defaultData().extConfig.wechatTimelineData.url = "http://www.airourou.me/topic/\(self.TopicId)"
        
        
        UMSocialData.defaultData().extConfig.qqData.title = self.topic!["title"].string
        UMSocialData.defaultData().extConfig.qqData.url = "http://www.airourou.me/topic/\(self.TopicId)"
        
        let shareSns = [UMShareToWechatSession, UMShareToWechatTimeline, UMShareToSina, UMShareToQzone, UMShareToQQ]
        UMSocialSnsService.presentSnsIconSheetView(self, appKey: UIConstant.UMAppKey, shareText: self.topic!["share"]["content"].string, shareImage: nil, shareToSnsNames: shareSns, delegate: self)
        
    }
    func moreClicked() {
        if self.topic == nil {
            return
        }
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let deleteAction = UIAlertAction(title: "删除话题", style:.Destructive) { _ in
            let vc = UIAlertController(title: "删除话题？", message: nil, preferredStyle: .Alert)
            vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            
            let action = UIAlertAction(title: "确定", style:.Default) { _ in
                let opt = try! HTTP.POST(UIConstant.AppDomain+"topic/remove", parameters: ["topic_id":self.TopicId])
                opt.start { response in
                    let json = JSON(data:response.data)
                    dispatch_sync(dispatch_get_main_queue()) {
                        if json["error_code"].int == 0 {
                            SVProgressHUD.showSuccessWithStatus("删除成功")
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            SVProgressHUD.showErrorWithStatus(json["message"].string)
                        }
                    }
                    
                }
                
                
            }
            vc.addAction(action)
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
        let reportAction = UIAlertAction(title: "举报话题", style:.Default) { _ in
            let vc = UIAlertController(title:nil, message: "请选择类型", preferredStyle: .ActionSheet)
            
            vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            let types = ["垃圾广告", "暴力色情", "人身攻击", "其他"]
            for _var in types {
                let ac = UIAlertAction(title:_var, style:.Default) { action in
                    let opt = try! HTTP.POST(UIConstant.AppDomain+"topic/report", parameters: ["topic_id":self.TopicId])
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
        
        let appendAction = UIAlertAction(title: "内容追加", style:.Default) { _ in
            let vc = AppendContentViewController()
            vc.TopicId = self.TopicId
            vc.Complete = {
                //self.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let copyAction = UIAlertAction(title: "拷贝话题链接", style: .Default,
                                       handler: { _ in
                                        let url = "http://www.airourou.me/topic/\(self.TopicId)"
                                        let p = UIPasteboard.generalPasteboard()
                                        p.string = url
                                        SVProgressHUD.showSuccessWithStatus("拷贝成功")
        })
        
        
        vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        vc.addAction(copyAction)
        vc.addAction(reportAction)
        
        if self.topic!["operation"]["delete"].bool == true {
            vc.addAction(deleteAction)
        }
        if self.topic!["operation"]["append"].bool == true {
            vc.addAction(appendAction)
        }
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    @objc private func hideKeyBoard() {
        self.keyboardBox.field.resignFirstResponder()
    }
    
    
    func setupKeyBoardView() {
        self.view.addSubview(self.keyboardBox)
        
        self.keyboardBox.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(0)
            make.right.left.equalTo(0)
            make.height.equalTo(52)
        }
        self.keyboardBox.button.addTarget(self, action: #selector(TopicViewController.sendReply), forControlEvents: .TouchUpInside)
        self.keyboardBox.field.delegate = self
        self.keyboardBox.likeComplete = {
            if self.topic == nil {
                return
            }
            let opt = try! HTTP.POST(UIConstant.AppDomain+"topic/like", parameters: ["topic_id":self.TopicId])
            opt.start { response in
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    if json["error_code"].int == 0 {
                        SVProgressHUD.showSuccessWithStatus(json["message"].string)
                    } else {
                        SVProgressHUD.showErrorWithStatus(json["message"].string)
                    }
                }
            }
        }
        // end like
        self.view.addSubview(self.keyboardUser)
        keyboardUser.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(0)
            make.bottom.equalTo(keyboardBox.snp_top).offset(0)
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        KeyboardHelper.defaultHelper.addDelegate(self)
    }
    
}

enum TopicViewTableViewSection: Int {
    case Header = 0, Comment, Other
}
extension TopicViewController:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let _section = TopicViewTableViewSection(rawValue: indexPath.section)!
        switch _section {
        case .Header:
            let row = self.topic!["rows"].array![indexPath.row]
            if row["type"].string == "html" {
                if self.webViewContentCell?.contentHeight > 0 {
                    return self.webViewContentCell!.contentHeight
                }
                else {
                    return 50
                }
            }
        default:
            break
        }
        return UITableViewAutomaticDimension
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _section = TopicViewTableViewSection(rawValue: section)!
        switch _section {
        case .Header:
            return self.topic != nil ? self.topic!["rows"].count :0
        case .Comment:
            return self.replies.count
            
        case .Other:
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let _section = TopicViewTableViewSection(rawValue: indexPath.section)!
        switch _section {
        case .Header:
            let row = self.topic!["rows"].array![indexPath.row]
            switch row["type"].string {
            case "head"?:
                let cell = getCell(tableView, cell: TopicHeadCell.self, indexPath: indexPath)
                cell.bind(row, nav:self.navigationController!)
                return cell
            case "html"?:
                if self.webViewContentCell == nil {
                    self.webViewContentCell = getCell(tableView, cell: TopicHtmlCell.self, indexPath: indexPath);
                } else {
                    return self.webViewContentCell!
                }
                self.webViewContentCell!.bind(row, pics: self.topic!["pics_url"], nav: self)
                self.webViewContentCell!.contentHeightChanged = { [weak self] (height:CGFloat) -> Void  in
                    if let weakSelf = self {
                        weakSelf.hideLoadingView()
                        //在cell显示在屏幕时更新，否则会崩溃会崩溃会崩溃
                        if weakSelf.tableView.visibleCells.contains(weakSelf.webViewContentCell!) {
                            if weakSelf.webViewContentCell?.contentHeight > 1.5 * AppHeight { //太长了就别动画了。。
                                UIView.animateWithDuration(0, animations: { () -> Void in
                                    self?.tableView.beginUpdates()
                                    self?.tableView.endUpdates()
                                })
                            }
                            else {
                                self?.tableView.beginUpdates()
                                self?.tableView.endUpdates()
                            }
                        }
                    }
                }
                return self.webViewContentCell!
            
            case "extend"?:
                let cell = getCell(tableView, cell: TopicExtendCell.self, indexPath: indexPath)
                cell.bind(row)
                return cell
            default:
                break
            }
        case .Comment:
            let row = self.replies[indexPath.row]
            
            switch row["type"].string {
            case "reply"?,"reply_to"?:
                var cell:TopicReplyCell
                if row["type"].string == "reply" {
                    cell = getCell(tableView, cell: TopicReplyCell.self, indexPath: indexPath)
                } else {
                    cell = getCell(tableView, cell: TopicReplyToCell.self, indexPath: indexPath)

                }
                cell.bind(row, nav:self)
                cell.replyComplete = { id in
                    self.keyboardUser.hidden = false
                    self.keyboardUser.avatarView.ar_setImageWithURL(row["user"]["avatar_url"].string!)
                    self.keyboardUser.content.text = "@\(row["user"]["nickname"].string!) \(row["content"].string!)"
                    self.replyId = id
                    
                    self.keyboardBox.field.becomeFirstResponder()
                }
                return cell
            default:
                break
            }
            
        default:
            break
        }
        return TopicBaseCell()
    }
    
    func sendReply() {
        if keyboardBox.field.text == "" {
            SVProgressHUD.showErrorWithStatus("抱歉, 请先输入评论内容")
            return
        }
        if AuthHelper.sharedInstance.isLogin() == false {
            SVProgressHUD.showErrorWithStatus("抱歉, 您还未登录!")
            return
        }
        let params:Dictionary<String,AnyObject> = [
            "topic_id":self.TopicId,
            "father_id":self.replyId,
            "content":keyboardBox.field.text
        ]
        
        let opt = try! HTTP.POST(UIConstant.AppDomain+"topic/reply", parameters:params)
        SVProgressHUD.showWithStatus("评论提交中...")
        opt.start { response in
            if response.error == nil {
                let json = JSON(data:response.data)
                dispatch_sync(dispatch_get_main_queue()) {
                    if json["error_code"].int == 0 {
                        SVProgressHUD.showSuccessWithStatus(json["message"].string)
                        self.keyboardBox.field.text = ""
                        self.keyboardBox.field.resignFirstResponder()
                        self.replies.append(json["last_reply"])
                        self.tableView.reloadData()
                    } else {
                        SVProgressHUD.showErrorWithStatus(json["message"].string)
                    }
                }
            }
        }
    }
    
}

extension TopicViewController:UITextViewDelegate {
    func  textViewDidChange(textView: UITextView) {
        var height = textView.contentSize.height
        if height <= 50 {
            height = 52
        } else {
            height = height + 8
        }
        if height > 75 {
            height = 74
        }
        self.keyboardBox.snp_updateConstraints { (make) -> Void in
            make.height.equalTo(height)
        }
        UIView.animateWithDuration(0.25) {
            self.keyboardBox.layoutIfNeeded()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let _section = TopicViewTableViewSection(rawValue: indexPath.section)!
        if _section != .Comment {
            return
        }
        let data = self.replies[indexPath.row]
        
        let vc = UIAlertController(title:nil, message:nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        vc.addAction(cancelAction)
        
        let reportAction = UIAlertAction(title: "举报", style:.Default) { _ in
            let rvc = UIAlertController(title:nil, message: "请选择类型", preferredStyle: .ActionSheet)
            
            rvc.addAction(cancelAction)
            let types = ["垃圾广告", "暴力色情", "人身攻击", "其他"]
            for _var in types {
                let ac = UIAlertAction(title:_var, style:.Default) { action in
                    SVProgressHUD.showSuccessWithStatus("举报成功")
                    /*
                     AirouApi.sharedInstance.request(.ReplyReport(replyId:data["_id"].int!, type:action.title!), completion: { (result) -> () in
                     SVProgressHUD.showSuccessWithStatus("举报成功")
                     })*/
                }
                rvc.addAction(ac)
            }
            self.presentViewController(rvc, animated: true, completion: nil)
        }
        vc.addAction(reportAction)
        
        
        let deleteAction = UIAlertAction(title: "删除", style:.Destructive) { _ in
            
            let vc = UIAlertController(title: "删除回复？", message: nil, preferredStyle: .Alert)
            vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            
            let action = UIAlertAction(title: "确定", style:.Destructive) { _ in
                let opt = try! HTTP.POST(UIConstant.AppDomain+"topic/reply/remove", parameters: ["reply_id":data["_id"].int!])
                opt.start { response in
                    if response.error == nil {
                        let json = JSON(data:response.data)
                        dispatch_sync(dispatch_get_main_queue()) {
                            if json["error_code"].int == 0 {
                                SVProgressHUD.showSuccessWithStatus(json["message"].string)
                                self.replies.removeAtIndex(indexPath.row)
                                self.tableView.reloadData()
                            } else {
                                SVProgressHUD.showErrorWithStatus(json["message"].string)
                            }
                        }
                        
                    }
                    
                }
            }
            vc.addAction(action)
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
        if data["operation"]["delete"].bool == true {
            vc.addAction(deleteAction)
        }
        
        let bestAction =  UIAlertAction(title: "采纳", style:.Default) { _ in
            let vc = UIAlertController(title: "确定采纳该回复么？该操作不可撤销", message: nil, preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Destructive, handler: { _ in
                let params = [
                    "topic_id":self.TopicId,
                    "reply_id":data["_id"].int!
                ]
                let opt = try! HTTP.POST(UIConstant.AppDomain+"topic/reply/best", parameters: params)
                opt.start { response in
                    if response.error == nil {
                        let json = JSON(data:response.data)
                        dispatch_sync(dispatch_get_main_queue()) {
                            if json["error_code"].int == 0 {
                                SVProgressHUD.showSuccessWithStatus("采纳成功")
                                let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopicReplyCell
                                cell.bestIconView.hidden = false
                            } else {
                                SVProgressHUD.showErrorWithStatus(json["message"].string)
                            }
                        }
                    }
                    
                }
                
            })
            vc.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            vc.addAction(action)
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        if data["operation"]["best"].bool == true {
            vc.addAction(bestAction)
        }
        
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}

extension TopicViewController:KeyboardHelperDelegate {
    func keyboardHelper(keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState) {
        let coveredHeight = state.intersectionHeightForView(self.view)
        self.keyboardBox.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(-coveredHeight)
        }
        self.maskView.hidden = false
        UIView.animateWithDuration(state.animationDuration) {
            UIView.setAnimationCurve(state.animationCurve)
            self.keyboardBox.layoutIfNeeded()
            self.keyboardUser.layoutIfNeeded()
        }
    }
    func keyboardHelper(keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState) {
        
    }
    func keyboardHelper(keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState) {
        self.keyboardBox.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(0)
        }
        self.maskView.hidden = true
        self.keyboardUser.hidden = true
        self.replyId = 0
        UIView.animateWithDuration(state.animationDuration) {
            UIView.setAnimationCurve(state.animationCurve)
            self.keyboardBox.layoutIfNeeded()
            self.keyboardUser.layoutIfNeeded()
        }
    }
}

extension TopicViewController:UMSocialUIDelegate {
    func didFinishGetUMSocialDataInViewController(response: UMSocialResponseEntity!) {
        if response.responseCode == UMSResponseCodeSuccess {
            SVProgressHUD.showSuccessWithStatus("分享成功")
        } else {
            SVProgressHUD.showErrorWithStatus("分享失败")
        }
    }
}
