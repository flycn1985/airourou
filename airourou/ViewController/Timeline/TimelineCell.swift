//
//  TimelineCell.swift
//  爱肉肉
//
//  Created by isno on 16/4/6.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import SwiftyJSON

class TimelineCell:UITableViewCell {
    
    var forwardComplete:(() -> Void)?
    var deleteComplete:(() -> Void)?
    
    private var collectionView:UICollectionView!
    
    private var pics:[String] = [String]()
    
    private var boxView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    private var point:UIView = {
        let view = UIView()
        view.backgroundColor = UIConstant.FontLightColor
        view.clipsToBounds = true
        view.layer.cornerRadius = 16/2
        return view
    }()
    
    var data:JSON = nil {
        didSet {
            self.content.text = data["content"].string
            self.plantAt.text = data["duration"].string
            
            self.pics = [String]()
            for _img in data["pics_url"] {
                self.pics.append(_img.1.string!)
            }
            var height:CGFloat = 0
            if self.pics.count > 0 {
                height = (AppWidth-38)/CGFloat(self.pics.count)
                if self.pics.count == 1 {
                    height = 250
                }
            }
            self.collectionView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(height).priority(900)
            })
            self.collectionView.reloadData()
            
        }
        
    }
    
    /** 帖子内容 */
    private var content:ArLabel = {
        let label = ArLabel()
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        label.font          = UIFont.systemFontOfSize(15)
        label.textColor     = UIColor(rgba: "#787878")
        return label
    }()
    
    private var plantAt:UILabel = {
        let label = UILabel()
        label.font          = UIFont.boldSystemFontOfSize(14)
        label.textColor     = UIColor.grayColor()
        return label
    }()
    
    
    var line:UIView = {
        let view = UIView()
        view.backgroundColor = UIConstant.FontLightColor
        return view
        
    }()
    
    
    private var forwardButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named:"icon_share2"), forState: .Normal)
        button.setTitle("分享到论坛", forState: .Normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(UIColor(rgba: "#adadad"), forState: .Normal)
        return button
    }()
    
    private var deleteButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named:"icon_delete"), forState: .Normal)
        button.setTitle("删除", forState: .Normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(UIColor(rgba: "#adadad"), forState: .Normal)
        return button
    }()

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIConstant.AppBackgroundColor
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.addSubview(line)
        line.snp_makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(0)
            make.width.equalTo(2)
            make.bottom.equalTo(0)
        }
        self.addSubview(point)
        point.snp_makeConstraints { (make) in
            make.centerX.equalTo(line)
            make.top.equalTo(0)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        self.addSubview(plantAt)
        plantAt.snp_makeConstraints { (make) in
            make.left.equalTo(point.snp_right).offset(8)
            make.centerY.equalTo(point)
        }
        self.addSubview(boxView)
        boxView.snp_makeConstraints { (make) in
            make.top.equalTo(plantAt.snp_bottom).offset(5)
            make.left.equalTo(point.snp_right).offset(5)
            make.right.equalTo(0)
            make.bottom.equalTo(-8)
        }

        boxView.addSubview(content)
        content.snp_makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(12)
            make.right.equalTo(-12)
        }
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 5, height: 5)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        
        collectionView = UICollectionView(frame:CGRectZero, collectionViewLayout:layout)
        collectionView.backgroundColor =  UIColor.whiteColor()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollEnabled = false
        
        collectionView.registerClass(TimlineImageCell.self, forCellWithReuseIdentifier: "timeline_image_cell")
        
        
        self.boxView.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.top.equalTo(content.snp_bottom).offset(8)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.height.equalTo(0).priority(900)
           
        }
        
        
        self.boxView.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(TimelineCell.deleted), forControlEvents: .TouchUpInside)
        deleteButton.snp_makeConstraints { (make) in
            make.right.equalTo(-16)
            make.top.equalTo(collectionView.snp_bottom).offset(8)
            make.bottom.equalTo(-12)
        }
        
        forwardButton.addTarget(self, action: #selector(TimelineCell.forward), forControlEvents: .TouchUpInside)
        self.boxView.addSubview(forwardButton)
        forwardButton.snp_makeConstraints { (make) in
            make.right.equalTo(deleteButton.snp_left).offset(-16)
            make.top.equalTo(collectionView.snp_bottom).offset(8)
        }
        
       
        
    }
    func forward() {
        if forwardComplete != nil {
            self.forwardComplete!()
        }
        
    }
    func deleted() {
        self.deleteComplete!()
    }
}

class TimlineImageCell: UICollectionViewCell {
    var imageView:UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .ScaleAspectFill
        return view
    }()
    required init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has nont been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.clearColor()
        
        self.addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
            make.left.top.equalTo(2)
            make.bottom.right.equalTo(-2)
        }

    }
}

extension TimelineCell:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.pics.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let pic = self.pics[indexPath.row] + "!middle.jpg"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("timeline_image_cell", forIndexPath: indexPath) as! TimlineImageCell
        cell.imageView.ar_setImageWithURL(pic)
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (AppWidth-48)/CGFloat(self.pics.count)
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let browser = GJPhotoBrowser()
        browser.dataSource = self
        browser.showWith(currentIndex: indexPath.row)
    }
}


extension TimelineCell:GJPhotoBrowserDataSource {
    func numberOfPhotosInPhotoBrowser(photoBrowser: GJPhotoBrowser) -> Int {
        return self.pics.count
    }
    func photoBrowser(photoBrowser: GJPhotoBrowser, viewForIndex index: Int) -> GJPhotoView {
        let photoView = photoBrowser.dequeueReusablePhotoView()
        let srcImageView = self.pics[index]+"!original.jpg"
        let urlStr = srcImageView
        photoView.setImageWithURL(urlStr)
        return photoView
    }
}


