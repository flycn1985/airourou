//
//  UpyunHelper.swift
//  爱肉肉
//
//  Created by isno on 16/1/13.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary
import DKImagePickerController

class UpYunFile {
    var path:String!
    var data:NSData?
    var assetURL:DKAsset!
    
    
    init(data:NSData?, withPath:String) {
        self.path = withPath
        self.data = data
    }
    convenience init(assetURL:DKAsset, withPath:String) {
        self.init(data:nil, withPath:withPath)
        self.path = withPath
        self.assetURL = assetURL
    }
}

class UpYunHelper:NSObject {
    
    static let sharedInstance = UpYunHelper()
    
    private let UploadURL: String = "http://v0.api.upyun.com"
    private let  spaceName: String = "airourou-pics"
    private let  operatorName: String = "isno"
    private let  operatorPasswd: String = "airourou1026"
    
    private var files:NSMutableArray!
    
    private var operationQueue:NSOperationQueue!
    
    
    private var uploadTask: NSURLSessionUploadTask?
 
    var uploadComplete:(() -> Void)?
    
    override init() {
        super.init()
        

        self.files = NSMutableArray()
        self.operationQueue = NSOperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
    }
    
    func addFile(file:UpYunFile) {
        self.files.addObject(file)
    }
    
    func startUpload() -> Bool {
        if self.files.count == 0 {
            if (self.uploadComplete != nil) {
                self.uploadComplete!()
            }
            return false
        }
        
        self.getFileSourceDataAndCreateOperation(0)
        
        return true
    }
    func GMTTimestamp() -> String {
        let date = NSDate()
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzzz"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.calendar =
            NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.stringFromDate(date)
    }
    /* 创建签名认证 */
    func createAuthorizationOperator(method: String, requestURL: String, ContentLength: Int, AuthorDate: String) -> String {
        
        let passwdMD5: String = self.operatorPasswd.md5!.lowercaseString
        
        /*Assembly ALL MESSAGE*/
        var Authorization: String = method + "&"
        Authorization += requestURL + "&"
        Authorization += AuthorDate + "&"
        Authorization += "\(ContentLength)" + "&"
        Authorization += passwdMD5
        //print(Authorization)
        /*MD5 ALL*/
        Authorization = Authorization.md5!.lowercaseString
        
        return Authorization
    }
    func upYunOperaction(index:Int, sourceData:NSData) -> NSOperation {
        let op = NSOperation()
        op.completionBlock = {
            let uploadDate = self.GMTTimestamp()
            let file = self.files[index] as! UpYunFile
            let filePath = "/\(self.spaceName)\(file.path)"
            let uploadAuthor: String = self.createAuthorizationOperator("PUT", requestURL:filePath, ContentLength: sourceData.length, AuthorDate: uploadDate)
            
            let uploadURLString: String =  "\(self.UploadURL)\(filePath)"
            let uploadRequestURL: NSURL = NSURL(string: uploadURLString)!
            let uploadRequest: NSMutableURLRequest = NSMutableURLRequest(URL: uploadRequestURL)
            
            uploadRequest.HTTPMethod = "PUT"
            uploadRequest.setValue(uploadDate, forHTTPHeaderField: "Date")
            uploadRequest.setValue("UpYun \(self.operatorName):\(uploadAuthor)",
                forHTTPHeaderField: "Authorization")

            self.uploadTask = NSURLSession.sharedSession().uploadTaskWithRequest(uploadRequest,fromData: sourceData) {
                (responseData, response, error) -> Void in
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if (index != self.files.count-1) {
                                self.getFileSourceDataAndCreateOperation(index+1)
                            }
                            if (index == self.files.count-1) {
                                if (self.uploadComplete != nil) {
                                    self.uploadComplete!()
                                }
                            }

                        }
                        
                    }
                                                                                
            }
            self.uploadTask!.resume()
        }
        return op
    }
    func getFileSourceDataAndCreateOperation(index:Int) {
        let file:UpYunFile = self.files[index] as! UpYunFile
        if file.data !=  nil {
            self.operationQueue.addOperation(self.upYunOperaction(index, sourceData: file.data!))
        } else {
            let op = PHImageRequestOptions()
            op.resizeMode = .Exact
            op.synchronous = true
            
            file.assetURL.fetchFullScreenImageWithCompleteBlock({ (image, info) -> Void in
                let data = UIImageJPEGRepresentation(image!,0.7)
                self.operationQueue.addOperation(self.upYunOperaction(index, sourceData:data!))

            })
        }
        }
    }
    
