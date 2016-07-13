//
//  RecordNewViewController.swift
//  爱肉肉
//
//  Created by isno on 3/31/16.
//  Copyright © 2016 isno. All rights reserved.
//
import Foundation
import UIKit
import MapKit
import Eureka
import SwiftyJSON
import SwiftHTTP
import SVProgressHUD
import MJRefresh

class RecordNewViewController: FormViewController {
    
    override func viewDidLoad() {
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: UITableViewStyle.Plain)
            tableView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleHeight)
        }
        super.viewDidLoad()
        self.title = "新增多肉"
        self.view.backgroundColor = UIColor.whiteColor()
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 8
                cell.accessoryView?.frame = CGRectMake(0, 0, 70, 70)
        }
            
        tableView?.backgroundColor  = UIColor.whiteColor()
        tableView!.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView?.layer.borderColor = UIColor.whiteColor().CGColor
        tableView?.scrollEnabled = true
        tableView?.sectionIndexBackgroundColor  = UIColor.whiteColor()
        tableView?.tableFooterView = UIView()
        
        
        
        form +++ Section() { section in
            section.header = .None
            }
            <<< ImageRow("image") {
                $0.title = "图片"
                }.cellSetup({ (cell, row) -> () in
                    cell.height = {90}
                    row.value = UIImage(named: "image_placehoder.png")
                })
            <<< TextRow("name"){
                $0.title = "名称"
                }.cellUpdate({ (cell, row) in
                cell.textField.font = UIFont.systemFontOfSize(16)
                cell.textField.placeholder = "给新养的肉肉起一个名称"
            })
            <<< DateRow("plant_data"){
                $0.title = "种植日期"
                $0.value =  NSDate()
                $0.maximumDate = NSDate()
                
            }.cellUpdate({ (cell, row) -> () in
                cell.selectionStyle = .None
                
            })
            <<< wikiRow("wiki") {
                $0.title = "关联百科"
                $0.value = WikiData()
        }
        
            // 设置发布按钮
        let addButton = UIBarButtonItem(title:"保存", style: .Plain, target: self, action: #selector(RecordNewViewController.saveData))
       
        self.navigationItem.rightBarButtonItem = addButton

    }
    func saveData() {
        let data =  self.form.values()
        guard let _ = data["name"] as? String else {
            SVProgressHUD.showErrorWithStatus("请填写肉肉名称")
            return
        }
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "YYYY-MM-dd"
        let plantData = dateFormat.stringFromDate(data["plant_data"] as! NSDate)
        
        let wiki = data["wiki"] as! WikiData
        
        let image = data["image"] as! UIImage
        let uploader = UpYunHelper.sharedInstance
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "/yyyy/M/dd/mmss"
        let basePath = dateFormatter.stringFromDate(NSDate())
        let filePath = "/uploads"+basePath+".jpg"
        
        uploader.addFile(UpYunFile(data: UIImageJPEGRepresentation(image, 0.6)!, withPath: filePath))
        
        let params:Dictionary<String,AnyObject> = [
            "title":data["name"] as! String,
            "plant_date":plantData,
            "baike_id":wiki.id,
            "pic_path":filePath,
        ]
        uploader.uploadComplete = {
            let opt = try! HTTP.POST(UIConstant.AppDomain+"record/new", parameters: params)
            opt.start { response in
                if response.error == nil {
                    dispatch_sync(dispatch_get_main_queue()) {
                        let json = JSON(data:response.data)
                        if json["error_code"].int == 0 {
                            SVProgressHUD.showSuccessWithStatus(json["message"].string!)
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            SVProgressHUD.showErrorWithStatus(json["message"].string!)
                        }
                    }
                } else {
                    SVProgressHUD.showErrorWithStatus("服务器请求错误")
                }
            }
        }
        SVProgressHUD.show()
        uploader.startUpload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


public class WikiData:NSObject {
    var id = 0
    var name = ""
}
public final class wikiRow : SelectorRow<WikiData, PushSelectorCell<WikiData>, WikisViewController>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return WikisViewController(){ _ in } }, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) })
        displayValueFor = {
            guard let location = $0 else { return "" }
            return location.name
        }
    }
}


public class WikisViewController : UIViewController, TypedRowControllerType, MKMapViewDelegate {
    
    // 百科数据
    var baikeData = [JSON]()
    
    public var row: RowOf<WikiData>!
    public var completionCallback : ((UIViewController) -> ())?
    
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var isSearched: Bool = false
    
    var arrSearch = [JSON]()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关联多肉百科"
        // 搜索条
        searchBar = UISearchBar(frame: CGRectMake(0, 0, AppWidth, 45))
        searchBar.placeholder = "搜索"
        searchBar.barStyle = UIBarStyle.Default
        searchBar.searchBarStyle = UISearchBarStyle.Default
        searchBar.barTintColor = UIColor(white: 0.9, alpha: 0.5)
        searchBar.translucent = true
        searchBar.showsCancelButton = true
        searchBar.showsSearchResultsButton = false
        searchBar.showsScopeBar = false
        searchBar.delegate = self
        
        self.view.addSubview(searchBar)
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor(rgba: "#f1f2f2")
        tableView.registerClass(WikiViewCell.self, forCellReuseIdentifier: "wiki_view_cell")
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = searchBar
        
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        let footer = MJRefreshAutoNormalFooter { () -> Void in
            if self.isSearched == true {
                return
            }
            var lastId = 0
            if self.baikeData.count > 0 {
                lastId = self.baikeData.last!["_id"].int!
            }
            do {
                let opt = try HTTP.GET(UIConstant.AppDomain+"wikis?last_id=\(lastId)")
                opt.start { response in
                    
                    if response.error == nil {
                        
                        dispatch_sync(dispatch_get_main_queue()) {
                            let json = JSON(data:response.data)
                            if json["error_code"].int == 0 {
                                
                                for _wiki in json["wikis"] {
                                    self.baikeData.append(_wiki.1)
                                }
                            }
                            self.tableView.reloadData()
                            self.tableView.mj_footer.endRefreshing()
                        }
                        
                    }
                }
            } catch {
                SVProgressHUD.showErrorWithStatus("服务请求错误")
            }
        }
        footer.refreshingTitleHidden = true
        footer.automaticallyHidden = true
        footer.stateLabel?.hidden = true
        
        self.tableView.mj_footer = footer
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        do {
            let opt = try HTTP.GET(UIConstant.AppDomain+"wikis")
            opt.start { response in
               
                if response.error == nil {
                    
                    dispatch_sync(dispatch_get_main_queue()) {
                        let json = JSON(data:response.data)
                        if json["error_code"].int == 0 {
                            for _wiki in json["wikis"] {
                                self.baikeData.append(_wiki.1)
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        } catch {
            SVProgressHUD.showErrorWithStatus("服务请求错误")
        }
        
        
    }
    
}
extension WikisViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearched {
            return arrSearch.count
        } else {
            return baikeData.count ?? 0
        }
    }
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var data:JSON
        if isSearched {
            data = arrSearch[indexPath.row]
        } else {
            data = baikeData[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("wiki_view_cell") as? WikiViewCell
        cell!.data = data
        
        return cell!
    }
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var data:JSON
        if isSearched {
            data = arrSearch[indexPath.row]
        } else {
            data = baikeData[indexPath.row]
        }
        let wiki = WikiData()
        wiki.id = data["_id"].int!
        wiki.name = data["name"].string!
        
        row.value? = wiki
        completionCallback?(self)
    }

}

extension WikisViewController: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearched = true
        arrSearch = [JSON]()
        
        do {
            let params = ["name":searchBar.text]
            let opt = try HTTP.GET(UIConstant.AppDomain+"wiki/search", parameters: params)
            opt.start { response in
                if response.error == nil {
                    let json = JSON(data: response.data)
                    if json["error_code"].int == 0 {
                        
                        dispatch_sync(dispatch_get_main_queue()) {
                            for _wiki in json["wikis"] {
                                self.arrSearch.append(_wiki.1)
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
        } catch {
            
        }
        

    }
    
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        isSearched = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    

}

/**
 * 百科表格cell
 *
 */
class WikiViewCell: UITableViewCell {
    
    var data: JSON! {
        didSet {
            
            name.text = data["name"].string
            desc.text = data["description"].string
            imageIcon.sd_setImageWithURL(NSURL(string:(data["image"].string!)))
        }
    }
    
    // 图片
    lazy var imageIcon: UIImageView = UIImageView()
    // 名字
    lazy var name: UILabel = UILabel()
    // 简介
    lazy var desc: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     * 设置子视图
     *
     */
    func setupViews() {
        
        // 图片
        imageIcon.translatesAutoresizingMaskIntoConstraints = false
        imageIcon.layer.cornerRadius = 3
        imageIcon.layer.masksToBounds = true
        
        self.contentView.addSubview(imageIcon)
        
        imageIcon.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(5)
            make.left.equalTo(10)
            make.bottom.equalTo(-5)
            make.size.equalTo(62)
        }
        
        // 名字
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = UIColor.blackColor()
        name.font = UIFont.systemFontOfSize(16)
        
        self.contentView.addSubview(name)
        
        name.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(8)
            make.left.equalTo(imageIcon.snp_right).offset(10)
        }
        
        // 简介
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.textColor = UIColor.grayColor()
        desc.font = UIFont.systemFontOfSize(12)
        desc.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        desc.numberOfLines = 2
        
        self.contentView.addSubview(desc)
        
        desc.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(name.snp_bottom).offset(5)
            make.left.equalTo(imageIcon.snp_right).offset(10)
            make.right.equalTo(self.contentView).offset(-10)
        }
    }
}
