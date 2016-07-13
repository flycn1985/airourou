//
//  AppDelegate+UMShare.swift
//  爱肉肉
//
//  Created by isno on 16/1/19.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
extension AppDelegate
{
    func setupUMeng() -> Void {
        
        
        UMSocialData.setAppKey(UIConstant.UMAppKey)
        
        UMSocialData.openLog(false)
        UMSocialConfig.setSupportedInterfaceOrientations(UIInterfaceOrientationMask.All)
        
        UMSocialData.defaultData().extConfig.wechatSessionData.title = "分享"
        UMSocialData.defaultData().extConfig.wechatSessionData.url = "http://www.airourou.me"
        UMSocialData.defaultData().extConfig.wxMessageType = UMSocialWXMessageTypeNone
        
        UMSocialWechatHandler.setWXAppId(UIConstant.WeixinAppID, appSecret: UIConstant.WeixinAppSecret, url: "http://www.airourou.me")

        UMSocialSinaSSOHandler.openNewSinaSSOWithAppKey("2872459577", secret: "2935e6c6e062a972e63d7dbcbd3509d9", redirectURL: "http://www.airourou.me/api/oauth/weibo/callback")
        
        UMSocialQQHandler.setQQWithAppId(UIConstant.QQAppID, appKey: UIConstant.QQAPPKEY, url: "http://www.airourou.me")
        
        /*
        
        

        
        UMSocialData.defaultData().extConfig.qqData.title = "分享"
        UMSocialData.defaultData().extConfig.qqData.url = "http://www.airourou.me"
        
        
        
       
       
        
        UMSocialConfig.hiddenNotInstallPlatforms([UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline])
        */
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let result = UMSocialSnsService.handleOpenURL(url)
        if result == false {
            
        }
        return result
    }

}