//
//  RecordInfoView.swift
//  爱肉肉
//
//  Created by isno on 16/4/5.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation

class RecordInfoView:UIView {

    private var boxView:UIView = {
        let view = UIView()
        return view
    }()
    var pageMaskView:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "page_mask")
        return view
    }()
    var imageView:UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .ScaleAspectFill
        view.userInteractionEnabled = true
        return view
    }()
    
    var plantDate:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor(rgba: "#fff")
        
        label.shadowColor=UIColor(rgba: "#666")
        label.shadowOffset=CGSizeMake(1, 1)
        
        return label
    }()
    
    var count:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor(rgba: "#fff")
        
        label.shadowColor=UIColor(rgba: "#666")
        label.shadowOffset=CGSizeMake(1, 1)
        
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.addSubview(boxView)
        boxView.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.left.equalTo(0)
            make.bottom.equalTo(0)
        }
        boxView.addSubview(imageView)
        
        imageView.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.left.equalTo(0)
            make.height.equalTo(140)
        }
        imageView.addSubview(pageMaskView)
        pageMaskView.snp_makeConstraints { (make) in
            make.bottom.right.left.equalTo(0)
            make.height.equalTo(60)
        }

        pageMaskView.addSubview(count)
        count.snp_makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.equalTo(-8)
        }
        
        pageMaskView.addSubview(plantDate)
        plantDate.snp_makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.equalTo(count.snp_top).offset(-5)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(rgba: "#e4e3e5")
       
        pageMaskView.addSubview(bottomLine)
        bottomLine.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(1)
            make.bottom.equalTo(0)
        }
        
    }
}