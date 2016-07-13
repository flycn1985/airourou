import UIKit
import Photos

import DKImagePickerController


class DKPreviewView: UIScrollView {
    let interval: CGFloat = 5
    var assets = [DKAsset]()
    private var imagesDict: [DKAsset : UIImageView] = [:]
    
    var showPickerCallback:(() -> ())?
    
    private var buttonView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonView)
        buttonView.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.height.equalTo(90)
            make.width.equalTo(180)
            make.left.equalTo(8)
        }
    
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "icon_image_add"), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(DKPreviewView.imageAdd), forControlEvents: UIControlEvents.TouchUpInside)
       
        buttonView.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(90)
            make.centerY.equalTo(buttonView)
            make.left.equalTo(0)
        }
        let tip = UILabel()
        tip.text = "添加照片"
        tip.font = UIFont.systemFontOfSize(16)
        tip.textColor = UIColor(rgba: "#999")
        tip.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(tip)
        tip.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(button.snp_right).offset(8)
            make.top.equalTo(18)
        }
        
        let tipNum = UILabel()
        tipNum.text = "最多添加9张"
        tipNum.font = UIFont.systemFontOfSize(12)
        tipNum.textColor = UIColor(rgba: "#999")
        tipNum.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(tipNum)
        tipNum.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(button.snp_right).offset(8)
            make.top.equalTo(tip.snp_bottom).offset(5)
        }
        
        //self.button.frame =  CGRect(x: 0, y: 0, width: 90, height: 90)
        
    }
    
    func imageAdd() {
        if self.showPickerCallback != nil {
            self.showPickerCallback!()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func imageFrameForIndex(index: Int) -> CGRect {
        let imageLengthOfSide = self.bounds.height - interval * 2
        
        return CGRect(x: CGFloat(index) * imageLengthOfSide + CGFloat(index + 1) * interval,
            y: (self.bounds.height - imageLengthOfSide)/2,
            width: imageLengthOfSide, height: imageLengthOfSide)
    }
    
    func updateButtonLayout() {
        let imageLengthOfSide = self.bounds.height - interval * 2
        let x = CGFloat(assets.count) * imageLengthOfSide + CGFloat(assets.count + 1) * interval
        self.buttonView.snp_updateConstraints { (make) -> Void in
            make.left.equalTo(x)
        }
        self.buttonView.layoutIfNeeded()
    }
    
    func insertAsset(asset: DKAsset) {
        asset.fetchImageWithSize(CGSize(width: 90*2, height: 90*2), completeBlock: { image,info -> Void in
            let imageView = UIImageView(image: image!)
            imageView.frame = self.imageFrameForIndex(self.assets.count)
            imageView.clipsToBounds = true
            imageView.contentMode = .ScaleAspectFill
            self.addSubview(imageView)
            self.assets.append(asset)
            self.imagesDict.updateValue(imageView, forKey: asset)
            
            self.updateButtonLayout()
            self.setupContent(true)
        })
        
    }
    
    func removeAsset(asset: DKAsset) {
        imagesDict.removeValueForKey(asset)?.removeFromSuperview()
        let index = assets.indexOf(asset)
        if let toRemovedIndex = index {
            assets.removeAtIndex(toRemovedIndex)
            setupContent(false)
        }
        
    }
    
    func replaceAssets(assets: [DKAsset]) {
        for _asset in self.assets {
            self.removeAsset(_asset)
        }
        self.imagesDict = [:]
        self.assets = []

        for asset in assets {
            self.insertAsset(asset)
        }
        self.updateButtonLayout()
    }
    
    private func setupContent(isInsert: Bool) {
        if isInsert == false {
            for (index,asset) in assets.enumerate() {
                let imageView = imagesDict[asset]!
                imageView.frame = imageFrameForIndex(index)
            }
        }
        let imageLengthOfSide = self.bounds.height - interval * 2
        let width = imageLengthOfSide*CGFloat(self.assets.count+2) + interval*CGFloat(self.assets.count+2)
        self.contentSize = CGSize(width: width,
            height: self.bounds.height)
    }
}
