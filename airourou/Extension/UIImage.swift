//
//  UIImage.swift
//  airourou
//
//  Created by isno on 16/4/21.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
    
    static func imageWithColor(color: UIColor) -> UIImage {
        let pixelScale = UIScreen.mainScreen().scale
        let pixelSize = 1 / pixelScale
        let fillSize = CGSize(width: pixelSize, height: pixelSize)
        let fillRect = CGRect(origin: CGPoint.zero, size: fillSize)
        UIGraphicsBeginImageContextWithOptions(fillRect.size, false, pixelScale)
        let graphicsContext = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(graphicsContext, color.CGColor)
        CGContextFillRect(graphicsContext, fillRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}

