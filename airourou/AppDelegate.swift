//
//  AppDelegate.swift
//  airourou
//
//  Created by isno on 16/4/13.
//  Copyright © 2016年 isno. All rights reserved.
//

import UIKit

import SwiftHTTP
import SwiftyJSON

import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setupUMeng()
        
        HTTP.globalRequest { req in
            req.timeoutInterval = 5
            
            for (key,value) in reqHeaders() {
                req.addValue(value, forHTTPHeaderField: key)
            }
        }
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setDefaultMaskType(.Clear)
        SVProgressHUD.setCornerRadius(6)
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.setBackgroundColor(UIColor(rgba: "#30333c").colorWithAlphaComponent(0.9))
        
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        
        KeyboardHelper.defaultHelper.startObserving()
        
        
        NSOperationQueue().addOperationWithBlock({ () -> Void in
            self.initRong()
        })
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = MainTabBarController()
        
        self.window!.makeKeyAndVisible()
        
        
        
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        RCIMClient.sharedRCIMClient().recordLaunchOptionsEvent(launchOptions)
        
        let pushServiceData = RCIMClient.sharedRCIMClient().getPushExtraFromLaunchOptions(launchOptions)
        if (pushServiceData != nil) {
            NSLog("该启动事件包含来自融云的推送服务");
            print(pushServiceData)
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.didReceiveMessageNotification(_:)), name: RCKitDispatchMessageNotification, object: nil)
        
        return true
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        
         print(token)
         RCIMClient.sharedRCIMClient().setDeviceToken(token)

    }
    func didReceiveMessageNotification(notification:NSNotification) {
        let message = notification.object as! RCMessage
        if message.messageDirection == RCMessageDirection.MessageDirection_RECEIVE {
            let num = UIApplication.sharedApplication().applicationIconBadgeNumber
           //UIApplication.sharedApplication().applicationIconBadgeNumber = num+2
        }
        
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        RCIMClient.sharedRCIMClient().recordLaunchOptionsEvent(userInfo)
        let pushServiceData = RCIMClient.sharedRCIMClient().getPushExtraFromRemoteNotification(userInfo)
        if (pushServiceData != nil) {
           //print(pushServiceData)
        }
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let unreadMsgCount = RCIMClient.sharedRCIMClient().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue,RCConversationType.ConversationType_SYSTEM.rawValue])
        //application.applicationIconBadgeNumber = Int(unreadMsgCount)
    }
    

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func initRong(){
        RCIM.sharedRCIM().initWithAppKey("4z3hlwrv3ihct")
        RCIM.sharedRCIM().receiveMessageDelegate = self
        RCIM.sharedRCIM().userInfoDataSource = self
        RCIM.sharedRCIM().portraitImageViewCornerRadius = 38
        RCIM.sharedRCIM().globalConversationAvatarStyle = .USER_AVATAR_CYCLE
        RCIM.sharedRCIM().globalMessageAvatarStyle = .USER_AVATAR_CYCLE
        RCIM.sharedRCIM().globalConversationPortraitSize = CGSizeMake(38, 38)
        RCIM.sharedRCIM().globalMessagePortraitSize = CGSizeMake(38, 38)
        RCIM.sharedRCIM().enableMessageAttachUserInfo = true
        
        
        if AuthHelper.sharedInstance.isLogin() == false {
            return
        }
        
        let opt = try! HTTP.GET(UIConstant.AppDomain+"profile")
        opt.start { response in
            dispatch_sync(dispatch_get_main_queue()) {
                let json = JSON(data:response.data)
                RCIM.sharedRCIM().connectWithToken(json["rong_token"].string,
                    success: { (userId) -> Void in
                        let nickname = json["nickname"].string
                        let avatarUrl = json["avatar_url"].string
                        let userId = String(json["id"].int!)
                        let userInfo = RCUserInfo(userId:userId, name: nickname, portrait: avatarUrl)
                        RCIM.sharedRCIM().currentUserInfo = userInfo
                        print("登陆成功。当前登录的用户ID：\(userId)")
                    }, error: { (status) -> Void in
                        print("登陆的错误码为:\(status.rawValue)")
                    }, tokenIncorrect: {
                        
                        
                })

            }
            
        }
    }
}

extension AppDelegate:RCIMUserInfoDataSource,RCIMReceiveMessageDelegate {
    
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        
        let opt = try! HTTP.GET(UIConstant.AppDomain+"user/\(userId)")
        opt.start  { response in
            dispatch_sync(dispatch_get_main_queue()) {
                let json = JSON(data:response.data)
                if json["error_code"].int == 0 {
                    let userinfo = RCUserInfo(userId: String(json["id"].int), name: json["nickname"].string!, portrait: json["avatar_url"].string!)
                    return completion(userinfo)
                }
            }
        }
    }
    func onRCIMReceiveMessage(message: RCMessage!, left: Int32) {
        //self.currentUser = message.content.senderUserInfo
    }
    

}

func reqHeaders() -> [String: String] {
    let device = UIDevice.currentDevice()
    let identifier = device.identifierForVendor
    var uuid = "null"
    if identifier != nil {
        uuid = identifier!.UUIDString
    }
    
    let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
    let version = nsObject as! String
    
    var headers = [String: String]()
    headers["X-Mobile-App-Token"] = AuthHelper.sharedInstance.getToken().base64
    headers["X-Mobile-App"] = "true"
    headers["x-Mobile-App-UUID"] = uuid
    headers["X-Mobile-App-Device"] = device.model
    headers["X-Mobile-App-OSVersion"] = device.systemVersion
    headers["X-Mobile-App-Platform"] = "iOS"
    headers["X-Mobile-App-Version"] = version
    headers["User-Agent"] = device.model
    headers["X-Mobile-App-DeviceCode"] = UIDevice.currentDevice().deviceModel
    
    return headers
}

