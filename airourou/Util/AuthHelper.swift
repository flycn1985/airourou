//
//  Auth.swift
//  爱肉肉
//
//  Created by isno on 16/1/12.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation

class AuthHelper {
    static let sharedInstance = AuthHelper()
    
    internal func isLogin() -> Bool {
        let token = self.getToken()
        if (token  != ""){
            return true
        }
        return false
    }
    internal func setLogin(uid:Int, token:String){
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
        NSUserDefaults.standardUserDefaults().setObject(uid, forKey: "uid")
        
    }
    internal func getToken() -> String {
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey("token") else {
            return ""
        }
        return token
    }
    func getUid() -> Int {
        let uid = NSUserDefaults.standardUserDefaults().integerForKey("uid")
        return uid
    }
    func logout() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("uid")
    }
}