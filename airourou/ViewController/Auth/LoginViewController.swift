//
//  LoginViewController.swift
//  爱肉肉
//
//  Created by isno on 16/1/29.
//  Copyright © 2016年 isno. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON
import SVProgressHUD
import SwiftHTTP

class LoginViewController: FormViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "登录/注册"
        self.view.backgroundColor = UIColor.whiteColor()
        
        let tip = UILabel()
        tip.translatesAutoresizingMaskIntoConstraints = false
        tip.font = UIFont.systemFontOfSize(13)
        tip.numberOfLines = 0
        tip.textColor = UIColor(rgba: "#999")
        tip.text = "注册手机号只在登录时使用。不用担心，爱肉肉不会公开你的手机号码！"
        
        self.view.addSubview(tip)
        
        tip.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.top.equalTo(15)
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
            <<< QuickLoginRow("phone").cellUpdate({ (cell, row) -> () in
                cell.selectionStyle = .None
                cell.textField.font = UIFont.systemFontOfSize(16)
                
            })
            <<< PhoneRow("validCode").cellUpdate({ (cell, row) -> () in
                cell.textField.placeholder = "输入收到的验证码"
                cell.textField.font = UIFont.systemFontOfSize(16)
                cell.selectionStyle = .None
            })
        tableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(tip.snp_bottom).offset(12)
            make.left.right.equalTo(0)
            make.height.equalTo(150)
            
        })
        
        let quickButton = UIButton(type: .Custom)
        quickButton.setTitle("快速登录", forState: .Normal)
        quickButton.setTitleColor(UIColor(rgba: "#fff"), forState: .Normal)
        quickButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        quickButton.backgroundColor = UIColor(rgba: "#6c9f00")
        quickButton.layer.borderColor = UIColor(rgba: "#669503").CGColor
        quickButton.layer.borderWidth = 1.0
        
        quickButton.layer.cornerRadius = 6
        quickButton.clipsToBounds = true
        quickButton.addTarget(self, action: #selector(LoginViewController.quickLogin), forControlEvents: .TouchUpInside)
        self.view.addSubview(quickButton)
        
        quickButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(16)
            make.height.equalTo(46)
            make.right.equalTo(-16)
            make.top.equalTo(tableView!.snp_bottom).offset(8)
        }
        
        let intro = UILabel()
        intro.translatesAutoresizingMaskIntoConstraints = false
        intro.font = UIFont.systemFontOfSize(12)
        intro.textColor = UIColor(rgba: "#999")
        intro.text = "点击下一步表示同意 使用协议和隐私条款"
        
        self.view.addSubview(intro)
        
        intro.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(quickButton.snp_bottom).offset(12)
        }
        
        let quickline = UIView()
        quickline.backgroundColor = UIColor(rgba: "#777")
        self.view.addSubview(quickline)
        quickline.snp_makeConstraints { (make) in
            make.top.equalTo(intro.snp_bottom).offset(32)
            make.height.equalTo(0.8)
            make.width.equalTo(280)
            make.centerX.equalTo(self.view.snp_centerX)
        }
        
        let quickText = UILabel()
        quickText.text = "第三方登录"
        quickText.backgroundColor = UIColor.whiteColor()
        quickText.font = UIFont.systemFontOfSize(14)
        quickText.textColor = UIColor(rgba: "#676767")
        
        self.view.addSubview(quickText)
        quickText.snp_makeConstraints { (make) in
            make.centerY.equalTo(quickline.snp_centerY)
            make.centerX.equalTo(self.view.snp_centerX)
        }
        
        
        let qqButton = UIButton(type: .Custom)
        qqButton.setImage(UIImage(named: "icon_qq")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        qqButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        qqButton.tintColor = UIColor(rgba: "#474747")
        qqButton.addTarget(self, action: #selector(LoginViewController.QQClicked), forControlEvents: UIControlEvents.TouchUpInside)

        
        self.view.addSubview(qqButton)
        qqButton.snp_makeConstraints { (make) in
            make.top.equalTo(quickText.snp_bottom).offset(28)
            make.right.equalTo(self.view.snp_centerX).offset(-8)
        }
        
        let weiboButton = UIButton(type: .Custom)
        weiboButton.setImage(UIImage(named: "icon_weibo")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        weiboButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        weiboButton.tintColor = UIColor(rgba: "#474747")
        weiboButton.addTarget(self, action: #selector(LoginViewController.weiboClicked), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.view.addSubview(weiboButton)
        weiboButton.snp_makeConstraints { (make) in
            make.top.equalTo(quickText.snp_bottom).offset(28)
            make.left.equalTo(self.view.snp_centerX).offset(8)
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func QQClicked() {
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToQQ)
        snsPlatform.loginClickHandler(self,UMSocialControllerService.defaultControllerService(),true,{(response:UMSocialResponseEntity!) ->Void in
            if(response.responseCode == UMSResponseCodeSuccess){
                var snsAccount = UMSocialAccountManager.socialAccountDictionary()
                let qqUser:UMSocialAccountEntity =  snsAccount[UMShareToQQ] as! UMSocialAccountEntity
                
                let params:Dictionary<String,AnyObject> = [
                    "platform_name":"QQ",
                    "usid":qqUser.usid,
                    "username":qqUser.userName,
                    "access_token":qqUser.accessToken,
                    "access_secret":qqUser.accessSecret,
                    "icon_url":qqUser.iconURL,
                ]
                SVProgressHUD.show()
                let opt = try! HTTP.POST(UIConstant.AppDomain+"oauth/init", parameters: params)
                opt.start { response in
                    SVProgressHUD.dismiss()
                    if response.error == nil {
                        self.loginComplete(JSON(data:response.data))
                    }
                }
            } else {
                SVProgressHUD.showErrorWithStatus("QQ登录失败")
            }
        })
    }
    
    func weiboClicked() {
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToSina)
        snsPlatform.loginClickHandler(self,UMSocialControllerService.defaultControllerService(),true,{(response:UMSocialResponseEntity!) ->Void in
            if(response.responseCode == UMSResponseCodeSuccess){
                var snsAccount = UMSocialAccountManager.socialAccountDictionary()
                let qqUser:UMSocialAccountEntity =  snsAccount[UMShareToSina] as! UMSocialAccountEntity
                
                let params:Dictionary<String,AnyObject> = [
                    "platform_name":"weibo",
                    "usid":qqUser.usid,
                    "username":qqUser.userName,
                    "access_token":qqUser.accessToken,
                    "access_secret":qqUser.accessSecret,
                    "icon_url":qqUser.iconURL,
                ]
                SVProgressHUD.show()
                let opt = try! HTTP.POST(UIConstant.AppDomain+"oauth/init", parameters: params)
                opt.start { response in
                    SVProgressHUD.dismiss()
                    if response.error == nil {
                        self.loginComplete(JSON(data:response.data))
                    }
                }
            } else {
                SVProgressHUD.showErrorWithStatus("微博登录失败")
            }
        })
    }
    func loginComplete(loginInfo:JSON) {
        if loginInfo["error_code"].int == 0 {
            
            dispatch_sync(dispatch_get_main_queue()) {
                // 统计
                MobClick.profileSignInWithPUID(String(loginInfo["user_id"].int!))
                
                AuthHelper.sharedInstance.setLogin(loginInfo["user_id"].int!, token:loginInfo["auth_token"].string!)
                if loginInfo["is_init"].bool == false {
                    SVProgressHUD.showSuccessWithStatus("首次登录需要设置用户信息")
                    let vc  = InitViewController()
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    /*
                    if loginInfo["is_load_profile"].bool == true {
                        vc.reloadData(loginInfo)
                    }*/

                } else {
                    SVProgressHUD.showSuccessWithStatus("登录成功")
                    /** 聊天登录 */
                    NSOperationQueue().addOperationWithBlock({ () -> Void in
                        RCIM.sharedRCIM().connectWithToken(loginInfo["rong_token"].string,
                            success: { (userId) -> Void in
                                let nickname = loginInfo["nickname"].string
                                let avatarUrl = loginInfo["avatar_url"].string!
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
                }
                
            } // end  main
        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                SVProgressHUD.showErrorWithStatus(loginInfo["message"].string!)
            }
        }
    }
    func quickLogin() {
        let data =  self.form.values()
        guard let phone = data["phone"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写登录手机号")
            return
        }
        guard let validCode = data["validCode"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写短信验证码")
            return
        }
        SVProgressHUD.showWithStatus("正在登录中...")
        
        let params = ["mobile":phone, "valid_code":validCode]
        let opt = try! HTTP.POST(UIConstant.AppDomain+"auth/quick_login", parameters: params)
        opt.start  { response in
            if response.error == nil {
                self.loginComplete(JSON(data:response.data))
            }
            
        }
    }
}


final class QuickLoginRow: FieldRow<String, LoginCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
    }
}





class LoginCell: Cell<String>, CellType, UITextFieldDelegate,TextFieldCell {
    
    internal var textField : UITextField { return phoneField }
    
    var timer: NSTimer?
    var count = 60
    
    var phoneField:UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFontOfSize(14)
        view.placeholder = "请填写登录手机号"
        view.clearButtonMode = .WhileEditing
        view.keyboardType = .PhonePad
        
        return view
    }()
    
    var button:UIButton = {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.backgroundColor = UIConstant.FontLightColor.CGColor
        button.setTitle("发送验证码", forState: .Normal)
        button.backgroundColor = UIConstant.FontLightColor
        

        
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
       
        return button
    }()
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func setup() {
        super.setup()
        height = { 50 }
        selectionStyle = .None
        phoneField.delegate = self
        phoneField.addTarget(self, action: #selector(LoginCell.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(phoneField)
        phoneField.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(12)
            make.centerY.equalTo(self.contentView.snp_centerY)
        })
        
        self.contentView.addSubview(button)
        button.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(-8)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.left.equalTo(phoneField.snp_right).offset(12)
            make.width.equalTo(100)
        })
        button.addTarget(self, action: #selector(LoginCell.sendValidCode(_:)), forControlEvents: .TouchUpInside)
    }
    func sendValidCode(sender:UIButton){
        
        guard let phone = row.value else {
            SVProgressHUD.showErrorWithStatus("请填写手机号")
            return
        }
        SVProgressHUD.show()
        let mobile = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        if (regextestmobile.evaluateWithObject(phone) == true) {
            
            let opt = try! HTTP.POST(UIConstant.AppDomain+"auth/send_code", parameters: ["mobile":phone,"type":"signup"])
            opt.start { response in
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    if json["error_code"].int == 0 {
                        SVProgressHUD.showSuccessWithStatus("发送验证码成功")
                        self.timer =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(LoginCell.timeCountDown), userInfo: nil, repeats: true)
                        self.button.enabled = false
                        self.count = 60
                    
                    } else {
                        SVProgressHUD.showErrorWithStatus(json["message"].string)
                    }
                }
            }
        } else {
            SVProgressHUD.showErrorWithStatus("请填写正确的手机号")
        }
    }
    func timeCountDown() {
        if count == 0 {
            self.button.enabled = true
            self.timer?.invalidate()
            self.button.setTitle("发送验证码", forState: .Normal)
        }else{
            self.button.setTitle("请\(count)秒后 重试", forState: .Disabled)
            count -= 1
        }
    }
    
    func textFieldDidChange(textField : UITextField){
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        guard !textValue.isEmpty else {
            row.value = nil
            return
        }
 
        row.value = textField.text
    }
    
    //MARK: TextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        formViewController()?.beginEditing(self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        formViewController()?.endEditing(self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
}