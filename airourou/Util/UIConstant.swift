//
//  UIConstant.swift
//  爱肉肉
//
//  Created by isno on 16/1/5.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

public let AppWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
public let AppHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
public let AppScale = UIScreen.mainScreen().scale

public struct UIConstant {
    static let AppBackgroundColor = UIColor(rgba:"#eeeeee")
    static let FontLightColor = UIColor(rgba: "#48c840")
    // 用于分享
    static let UMAppKey = ""
    
    // 微信分享
    static let WeixinAppID = ""
    static let WeixinAppSecret = ""
    // QQ分享
    static let QQAppID =  ""
    static let QQAPPKEY = ""
    static let AppDomain = "http://www.airourou.me/api/"
    static let PicDomain = "http://airourou-pics.b0.upaiyun.com"
    static let ImageUploadScale:CGFloat = 0.5
    static let CachesPath: String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]

}
