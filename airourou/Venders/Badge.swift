//
//  Badge.swift
//  airourou
//
//  Created by isno on 16/4/13.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

class Badge: UILabel {
    var defaultInsets = CGSize(width: 2, height: 2)
    var actualInsets = CGSize()
    
    convenience init() {
        self.init(frame: CGRect())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.backgroundColor = UIColor(rgba: "#ff8000").CGColor
        textColor = UIColor.whiteColor()
        
        
    }
    
    // Add custom insets
    // --------------------
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let rect = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines)
        
        actualInsets = defaultInsets
        let rectWithDefaultInsets = CGRectInset(rect, -actualInsets.width, -actualInsets.height)
        
        // If width is less than height
        // Adjust the width insets to make it look round
        if rectWithDefaultInsets.width < rectWithDefaultInsets.height {
            actualInsets.width = (rectWithDefaultInsets.height - rect.width) / 2
        }
        
        return CGRectInset(rect, -actualInsets.width, -actualInsets.height)
    }
    
    override func drawTextInRect(rect: CGRect) {
        
        layer.cornerRadius = rect.height / 2
        
        let insets = UIEdgeInsets(
            top: actualInsets.height,
            left: actualInsets.width,
            bottom: actualInsets.height,
            right: actualInsets.width)
        
        let rectWithoutInsets = UIEdgeInsetsInsetRect(rect, insets)
        
        super.drawTextInRect(rectWithoutInsets)
    }
}