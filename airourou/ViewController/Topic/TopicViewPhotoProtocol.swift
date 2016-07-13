//
//  TopicViewPhotoProtocol.swift
//  爱肉肉
//
//  Created by isno on 16/4/8.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

extension TopicHtmlCell:GJPhotoBrowserDataSource {
    func numberOfPhotosInPhotoBrowser(photoBrowser: GJPhotoBrowser) -> Int {
        return self.pics!.count
    }
    func photoBrowser(photoBrowser: GJPhotoBrowser, viewForIndex index: Int) -> GJPhotoView {
        let photoView = photoBrowser.dequeueReusablePhotoView()
        let src = self.pics![index]
        photoView.setImageWithURL(src)
        return photoView
    }
}

