
//
//  UIImageView.swift
//  爱肉肉
//
//  Created by isno on 16/2/26.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func ar_setImageWithURL(url: String,  completed: SDWebImageCompletionBlock? = nil) {
        sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "image_placehoder.png"))
    }
}


