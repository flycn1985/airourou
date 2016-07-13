//
//  ArLabel.swift
//  爱肉肉
//
//  Created by isno on 16/4/12.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class ArLabel:UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    func sharedInit() {
        
        userInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ArLabel.showMenu(_:))))
        
    }
    
    func showMenu(sender:AnyObject) {
        
        becomeFirstResponder()
        let menu = UIMenuController.sharedMenuController()
        if !menu.menuVisible {
            menu.setTargetRect(bounds, inView: self)
            menu.setMenuVisible(true, animated: true)
            
        }
        
    }
    //复制功能
    
    override func copy(sender: AnyObject?) {
        let pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = text
        //点击复制后，菜单是否消失
        //        let menu = UIMenuController.sharedMenuController()
        //        menu.setMenuVisible(true, animated: true)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.copy(_:)) {
            return true
        }
        return false
    }
}