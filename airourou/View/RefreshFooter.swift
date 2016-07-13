//
//  RefreshFooter.swift
//  airourou
//
//  Created by isno on 16/5/3.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation

import UIKit
import MJRefresh

class RefreshFooter: MJRefreshAutoFooter {
    
    var loadingView:UIActivityIndicatorView?
    var stateLabel:UILabel?
    
    var centerOffset:CGFloat = 0
    
    private var _noMoreDataStateString:String?
    var noMoreDataStateString:String? {
        get{
            return self._noMoreDataStateString
        }
        set{
            self._noMoreDataStateString = newValue
            self.stateLabel?.text = newValue
        }
    }
    
    override var state:MJRefreshState{
        didSet{
            switch state {
            case .Idle:
                self.stateLabel?.text = nil
                self.loadingView?.hidden = true
                self.loadingView?.stopAnimating()
            case .Refreshing:
                self.stateLabel?.text = nil
                self.loadingView?.hidden = false
                self.loadingView?.startAnimating()
            case .NoMoreData:
                self.stateLabel?.text = self.noMoreDataStateString
                self.loadingView?.hidden = true
                self.loadingView?.stopAnimating()
            default:break
            }
        }
    }
    
    /**
     初始化工作
     */
    override func prepare() {
        super.prepare()
        self.mj_h = 50
        
        self.loadingView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.addSubview(self.loadingView!)
        
        self.stateLabel = UILabel(frame: CGRectMake(0, 0, 300, 40))
        self.stateLabel?.textAlignment = .Center
        self.stateLabel!.font = UIFont.systemFontOfSize(14)
        self.addSubview(self.stateLabel!)
        
        self.noMoreDataStateString = "没有更多数据了"
    }
    
    /**
     在这里设置子控件的位置和尺寸
     */
    override func placeSubviews(){
        super.placeSubviews()
        self.loadingView!.center = CGPointMake(self.mj_w/2, self.mj_h/2 + self.centerOffset);
        self.stateLabel!.center = CGPointMake(self.mj_w/2, self.mj_h/2  + self.centerOffset);
    }
    
}
