//
//  ARClient.swift
//  airourou
//
//  Created by isno on 16/5/4.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class ARClient: NSObject {
    static let sharedInstance = ARClient()
    
    var centerNavigation : MainNavigationController? = nil
    
    // 当前程序中，最上层的 NavigationController
    var topNavigationController : UINavigationController {
        get{
            return ARClient.getTopNavigationController(ARClient.sharedInstance.centerNavigation!)
        }
    }
    
    private class func getTopNavigationController(currentNavigationController:UINavigationController) -> UINavigationController {
        if let topNav = currentNavigationController.visibleViewController?.navigationController{
            if topNav != currentNavigationController && topNav.isKindOfClass(UINavigationController.self){
                return getTopNavigationController(topNav)
            }
        }
        return currentNavigationController
    }
}