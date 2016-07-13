//
//  PhotoBrowser.swift
//  爱肉肉
//
//  Created by isno on 16/4/8.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

protocol GJPhotoBrowserDataSource : NSObjectProtocol {
    func numberOfPhotosInPhotoBrowser(photoBrowser: GJPhotoBrowser) -> Int
    func photoBrowser(photoBrowser: GJPhotoBrowser, viewForIndex index: Int) -> GJPhotoView
}

class GJPhotoBrowser: UIViewController, UIScrollViewDelegate, GJPhotoViewDelegate {
    // MARK: - Property
    var currentIndex = 0 /// current photo index
    weak var dataSource: GJPhotoBrowserDataSource?
    
    private lazy var numberOfPhotos = 0
    private lazy var reusePhotoViewsPool = NSMutableSet()
    private lazy var visiblePhotoViewsPool = NSMutableSet()
    private var scrollView: UIScrollView!
    private var indexLabel: UILabel!
    private var indexRange = (-1, -1)
    private var animatedFlag = true
    
    private let margin: CGFloat = 10
    
    // MARK: - Public Method
    func dequeueReusablePhotoView() -> GJPhotoView {
        var photoView: GJPhotoView!
        if let p = reusePhotoViewsPool.anyObject() as? GJPhotoView {
            photoView = p
            reusePhotoViewsPool.removeObject(p)
        } else {
            photoView = GJPhotoView()
            photoView.photoViewDelegate = self
            photoView.photoBrowserView = self.view
        }
        return photoView
    }
    
    /**
     show with index 0
     */
    func show() {
        showWith(currentIndex: 0)
    }
    
    /**
     show with specify index, the index can't < 0
     */
    func showWith(currentIndex currentIndex: Int) {
        assert(currentIndex >= 0, "currentIndex不能小于0")
        self.currentIndex = currentIndex
        
        if let dataSource = self.dataSource {
            numberOfPhotos = dataSource.numberOfPhotosInPhotoBrowser(self)
        }
        
        if let window = UIApplication.sharedApplication().keyWindow {
            window.addSubview(self.view)
            window.rootViewController?.addChildViewController(self)
        }
        
        if self.currentIndex == 0 {
            showPhotoViews()
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIndexLabel()
        setupScrollView()
    }
    
    // MARK: - Add Views
    private func setupScrollView() {
        scrollView = UIScrollView()
        var frame = self.view.bounds
        frame.origin.x -= margin
        frame.size.width += 2 * margin
        scrollView.frame = frame
        self.view.insertSubview(scrollView, belowSubview: indexLabel)
        
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.contentSize = CGSizeMake(CGFloat(numberOfPhotos) * CGRectGetWidth(frame), 0)
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentOffset = CGPointMake(CGFloat(self.currentIndex) * frame.size.width, 0);
    }
    
    private func setupIndexLabel() {
        indexLabel = UILabel()
        let indexLabelW = self.view.bounds.size.width
        let indexLabelH: CGFloat = 21
        let indexLabelY = self.view.bounds.size.height - indexLabelH - 20
        indexLabel.frame = CGRect(x: 0, y: indexLabelY, width: indexLabelW, height: indexLabelH)
        indexLabel.textAlignment = .Center
        indexLabel.textColor = UIColor.whiteColor()
        indexLabel.font = UIFont.boldSystemFontOfSize(16)
        indexLabel.text = "\(currentIndex+1)/\(numberOfPhotos)"
        indexLabel.layer.cornerRadius = 5
        indexLabel.clipsToBounds = true
        indexLabel.backgroundColor = UIColor(white: 0.5, alpha: 0.3)
        self.view.addSubview(indexLabel)
        indexLabel.snp_makeConstraints { (make) in
            make.top.equalTo(30)
            make.width.equalTo(50)
            make.height.equalTo(32)
            make.centerX.equalTo(self.view)
        }
        
        let button = UIButton(type: .Custom)
        button.setTitle("保存", forState: .Normal)
        button.addTarget(self, action: #selector(GJPhotoBrowser.savePhoto), forControlEvents: .TouchUpInside)
        button.setTitleColor(UIColor(rgba: "#e8ca26"), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        self.view.addSubview(button)
        button.snp_makeConstraints { (make) in
            make.left.equalTo(18)
            make.bottom.equalTo(-20)
            make.width.equalTo(65)
            make.height.equalTo(32)
        }
        
    }
    
    func savePhoto() {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5)
        var i = 0
        for obj in visiblePhotoViewsPool {
            let photoView = obj as! GJPhotoView
            if i == index {
                UIImageWriteToSavedPhotosAlbum(photoView.getImage()!, self, #selector(GJPhotoBrowser.image(_:didFinishSavingWithError:contextInfo:)), nil)
                break
            }
            i+=1
        }
        
    }
    
    func image(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject)
    {
        if didFinishSavingWithError != nil
        {
            SVProgressHUD.showErrorWithStatus("保存出错")
            return
        }
        SVProgressHUD.showSuccessWithStatus("保存成功")

    }

    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5)
        indexLabel.text = "\(index+1)/\(numberOfPhotos)"
        showPhotoViews()
    }
    
    // MARK: - CustomDelegate
    // MARK: GJPhotoViewDelegate
    func photoViewDidSingleTap(photoView: GJPhotoView) {
        dismiss()
    }
    
    // MARK: - Private Method
    private func showPhotoViews() {
        if numberOfPhotos == 1 {
            showPhotoViewsAtIndex(0)
            return
        }
        
        let range = getIndexRnage()
        if indexRange.0 == range.0 && indexRange.1 == range.1 {
            return
        }
        indexRange = range
        
        queueReusablePhotoView()
        
        for index in indexRange.0...indexRange.1 {
            let showing = isShowingAtIndex(index)
            if !showing {
                showPhotoViewsAtIndex(index)
            }
        }
    }
    
    private func showPhotoViewsAtIndex(index: Int) {
        if dataSource == nil {return}
        let photoView = dataSource!.photoBrowser(self, viewForIndex: index)
        
        var frame = scrollView.bounds
        frame.origin.x = CGFloat(index) * CGRectGetWidth(frame) + margin
        frame.size.width -= 2 * margin
        photoView.frame = frame
        photoView.tag = index
        
        let animated = animatedFlag && self.currentIndex == index
        photoView.showImage(animated: animated)
        if animatedFlag {animatedFlag = false}
        
        scrollView.addSubview(photoView)
        visiblePhotoViewsPool.addObject(photoView)
    }
    
    private func getIndexRnage() -> (Int, Int) {
        let visibleBounds = scrollView.bounds
        let width = CGRectGetWidth(visibleBounds)
        let minX = CGRectGetMinX(visibleBounds) + margin
        let maxX = CGRectGetMaxX(visibleBounds) - margin
        var startIndex = Int(minX / width)
        var endIndex = Int(maxX / width)
        
        if startIndex < 0 {
            startIndex = 0
        }
        if endIndex > numberOfPhotos - 1 {
            endIndex = numberOfPhotos - 1
        }
        
        return (startIndex, endIndex)
    }
    
    private func isShowingAtIndex(index: Int) -> Bool {
        for obj in visiblePhotoViewsPool {
            let photoView = obj as! GJPhotoView
            if photoView.tag == index {
                return true
            }
        }
        return false
    }
    
    private func queueReusablePhotoView() {
        for obj in visiblePhotoViewsPool {
            let photoView = obj as! GJPhotoView
            if photoView.tag < indexRange.0 || photoView.tag > indexRange.1 {
                photoView.removeFromSuperview()
                reusePhotoViewsPool.addObject(photoView)
            }
        }
        
        visiblePhotoViewsPool.minusSet(reusePhotoViewsPool as Set<NSObject>)
    }
    
    private func dismiss() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismiss()
    }
}