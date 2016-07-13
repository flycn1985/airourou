//
//  TestViewController.swift
//  airourou
//
//  Created by 夏菁 on 15/11/5.
//  Copyright © 2015年 isno. All rights reserved.
//

import UIKit
import MJRefresh
import SVProgressHUD
import SwiftyJSON
import SwiftHTTP

class RecordViewController: BaseViewController {
    private var collectionView:UICollectionView!
    // 数据
    var datas = [JSON]()
    
    private var loginView = LoginView()
    
    private var timelineView = TimelineView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIConstant.AppBackgroundColor

        // 添加时光按钮
        let addButton = UIBarButtonItem(title: nil, style: .Done, target: self, action: #selector(RecordViewController.postRecordView))
        addButton.image = UIImage(named: "icon_post_new")
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.title = "我的多肉时光"
        
        self.setupCollection()
        
        self.view.addSubview(timelineView)
        timelineView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        timelineView.addCallback = {
            let vc = RecordNewViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }

        
        self.view.addSubview(loginView)
        self.view.bringSubviewToFront(loginView)
        loginView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        loginView.loginCallback = {
            self.navigationController!.pushViewController(LoginViewController(), animated: true)
        }
    }
    func setupCollection() {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: (AppWidth-16-16) / 2, height: (AppWidth-16-16) / 2)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        

        collectionView = UICollectionView(frame:CGRectZero, collectionViewLayout:layout)
        collectionView.backgroundColor =  UIConstant.AppBackgroundColor
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.registerClass(RecordViewCell.self, forCellWithReuseIdentifier: "record_view_cell")
        
        
        self.view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.top.equalTo(8)
            make.right.equalTo(-8)
            make.left.equalTo(8)
            make.bottom.equalTo(-8)
        }
        
        let header = RefreshHeader(refreshingBlock: { () -> Void in
            let opt = try! HTTP.GET(UIConstant.AppDomain+"records")
            opt.start { response in
            if response.error == nil {
                dispatch_sync(dispatch_get_main_queue()) {
                    let json = JSON(data:response.data)
                    self.datas = [JSON]()
                    for _data in json["data"] {
                        self.datas.append(_data.1)
                    }
                    if json["data"].count > 0 {
                        self.timelineView.hidden = true
                    } else {
                        self.timelineView.hidden = false
                    }
                    self.collectionView.mj_header.endRefreshing()
                    self.collectionView.reloadData()
                }
            }
        }
            
        })
        
        collectionView.mj_header = header
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (AuthHelper.sharedInstance.isLogin() == false) {
            loginView.hidden = false
        } else {
            loginView.hidden = true
            self.collectionView.mj_header.beginRefreshing()

        }
       
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     * 展示添加记录视图
     *
     */
    func postRecordView() {
        if (AuthHelper.sharedInstance.isLogin() == false) {
            return 
        }
        let vc = RecordNewViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RecordViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.datas.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("record_view_cell", forIndexPath: indexPath) as! RecordViewCell
        let data = self.datas[indexPath.row]
        cell.iconView.ar_setImageWithURL(data["pic_url"].string!)
        cell.name.text = data["title"].string!
        if data["statuses_count"].int == 0 {
            cell.updateAt.text = "还未添加记录"
            cell.updateAt.textColor = UIColor(rgba: "#adadad")
        } else {
            cell.updateAt.text = data["updated_at"].string
            if data["updated_days"].int < 7 {
                cell.updateAt.textColor = UIConstant.FontLightColor
            } else {
                cell.updateAt.textColor = UIColor(rgba: "#adadad")
            }
        }
        
        cell.plantDate.text = data["plant_days"].string

        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let data = self.datas[indexPath.row]
        let vc = TimelineViewController()
        vc.RecordId = data["_id"].int!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



class RecordViewCell: UICollectionViewCell {
    var iconView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    var name:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(15)
        label.textColor = UIColor(rgba: "#676767")
        return label
    }()
    
    var updateAt:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor(rgba: "#adadad")
        return label
    }()
    
    
    var plantDate:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor(rgba: "#adadad")
        return label
    }()
    
    required init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has nont been implemented")
    }
    
    private var boxView:UIImageView = {
        let view = UIImageView()
        
        view.image = UIImage(named: "record_bg")!
        let myInsets : UIEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        view.image = view.image!.resizableImageWithCapInsets(myInsets)
        
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.addSubview(boxView)
        boxView.snp_makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        
        
        boxView.addSubview(iconView)
        iconView.snp_makeConstraints { (make) in
            make.left.top.equalTo(2)
            make.right.equalTo(-2)
            make.height.equalTo(100)
        }
        
        boxView.addSubview(name)
        name.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.top.equalTo(iconView.snp_bottom).offset(6)
            make.right.equalTo(-8)
        }
        
        boxView.addSubview(plantDate)
        plantDate.snp_makeConstraints { (make) in
            make.top.equalTo(name.snp_bottom).offset(5)
            make.left.equalTo(8)
        }
        
        boxView.addSubview(updateAt)
        updateAt.snp_makeConstraints { (make) in
            make.top.equalTo(plantDate.snp_bottom).offset(5)
            make.left.equalTo(8)
        }
        
        
    }
}

