//
//  BoardTopicImageCell.swift
//  airourou
//
//  Created by isno on 10/3/15.
//  Copyright © 2015 isno. All rights reserved.
//

import UIKit
import SwiftyJSON

class TopicImageOneCell:TopicCell {
    
    private var collectionView:UICollectionView!
    
    private var imagesView:UIImageView!
    
    override var pics:JSON! {
        didSet {
            self.imagesView.ar_setImageWithURL(pics[0].string!)
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        
        imagesView = UIImageView()
        imagesView.contentMode = UIViewContentMode.ScaleAspectFill
        imagesView.clipsToBounds = true
        self.imageBoxView.addSubview(imagesView)
        imagesView.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(190)
            make.bottom.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

