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
    
    static let UMAppKey = "569dfd7ee0f55abf17000859"
    
    static let WeixinAppID = "wxdfd3c5c219106fcc"
    static let WeixinAppSecret = "d55853d22fedc63be63575a7ab069941"
    
    static let QQAppID =  "1105083994"
    static let QQAPPKEY = "DnqkGs1qkFDg3mvc"
    static let AppDomain = "http://www.airourou.me/api/"
    static let PicDomain = "http://airourou-pics.b0.upaiyun.com"
    static let ImageUploadScale:CGFloat = 0.5
    static let CachesPath: String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]

}