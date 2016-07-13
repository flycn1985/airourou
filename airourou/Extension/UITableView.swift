//
//  UITableView.swift
//  爱肉肉
//
//  Created by isno on 16/4/12.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

extension UITableView{
    func tableViewDisplayWitMsg(message:String,rowCount:NSInteger){
        if (rowCount == 0) {
            // Display a message when the table is empty
            // 没有数据的时候，UILabel的显示样式
            let messageLabel = UILabel()
            
            messageLabel.text = message as String
            messageLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            messageLabel.textColor = UIColor.lightGrayColor()
            messageLabel.textAlignment = NSTextAlignment.Center;
            messageLabel.sizeToFit()
            
            self.backgroundView = messageLabel;
            
        } else {
            self.backgroundView = nil;
        }
    }
    
}
extension NSObject {
    /**
     当前的类名字符串
     
     - returns: 当前类名的字符串
     */
    public class func Identifier() -> String {
        return "\(self)";
    }
}

func regClass(tableView:UITableView , cell:AnyClass)->Void {
    tableView.registerClass( cell, forCellReuseIdentifier: cell.Identifier());
}

func getCell<T: UITableViewCell>(tableView:UITableView ,cell: T.Type ,indexPath:NSIndexPath) -> T {
    return tableView.dequeueReusableCellWithIdentifier("\(cell)", forIndexPath: indexPath) as! T ;
}