//
//  NotifyHelper.swift
//  爱肉肉
//
//  Created by isno on 16/2/26.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation

class NotifyHelper {
    static let sharedInstance = NotifyHelper()
    
    func set( name:String, value:Bool) {
        let name = "notify_" + name
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: name)
    }
    func getValue( name:String) -> Bool {
        let name = "notify_" + name
        return NSUserDefaults.standardUserDefaults().boolForKey(name)
    }
    
}
