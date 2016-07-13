//
//  ImageRow.swift
//  爱肉肉
//
//  Created by isno on 16/2/11.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import Eureka
import UIKit
import MapKit

import SwiftyJSON
import SwiftHTTP
import MapKit
import SVProgressHUD


final class BaseRow: Row<String, BaseCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
    }
}

struct MapData {
    let isno:CLLocationCoordinate2D
    let name:String
    let address:String
}

public class BaseCell:Cell<String>,CellType {
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
        height = { 100 }
    }
    
    public override func update() {
        super.update()
        
    }
    public override func didSelect() {
        
        formViewController()?.tableView?.deselectRowAtIndexPath(row.indexPath()!, animated: true)
        row.updateCell()
    }
}

public class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private var userLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    private let locationManager:CLLocationManager = CLLocationManager()
    
    public var completionCallback : ((MapViewController) -> ())?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: (MapViewController) -> ()){
        self.init()
        completionCallback = callback
    }
    
    private var datas = [JSON]()
    
    var data:JSON = nil
    
    private var mainMapView: MKMapView!
    private var tableView:UITableView!
    
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView()
        v.image = UIImage(named: "icon_lbs_pin")
        v.clipsToBounds = true
        v.contentMode = .ScaleAspectFit
        v.userInteractionEnabled = false
        return v
        }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "我在这里"
        
        self.mainMapView = MKMapView()
        self.mainMapView.delegate = self
        self.view.addSubview(self.mainMapView)
        self.mainMapView.translatesAutoresizingMaskIntoConstraints = false
        self.mainMapView.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(250)
        }
        
        
        self.mainMapView.addSubview(pinView)
        pinView.translatesAutoresizingMaskIntoConstraints = false
        pinView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.mainMapView.snp_center)
        }
        
        self.mainMapView.mapType = MKMapType.Standard
        self.mainMapView.showsUserLocation = true
        
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "icon_lbs_button"), forState: .Normal)
        if #available(iOS 9.0, *) {
            button.setImage(UIImage(named: "icon_lbs_button_hl"), forState: .Focused)
        } else {
            // Fallback on earlier versions
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.mainMapView.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(-8)
            make.left.equalTo(8)
        }
        button.addTarget(self, action: #selector(MapViewController.locationPin), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.tableView = UITableView()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.tableView.separatorColor = UIColor(rgba: "#f1f2f2")
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.backgroundColor = Theme.BackgroundColor
        
        self.tableView.registerClass(LocationCell.self, forCellReuseIdentifier: "location_cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.mainMapView.snp_bottom).offset(1)
            make.left.equalTo(0)
            make.right.bottom.equalTo(0)
        }
        
        locationManager.requestAlwaysAuthorization()
        if (CLLocationManager.locationServicesEnabled() == false) {
            let alertView = UIAlertController(title: "定位未开启", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
    
    func locationPin() {
        let region = MKCoordinateRegionMakeWithDistance(self.userLocation, 250,250)
        self.mainMapView!.setRegion(region, animated: true)
    }
    // map
    
    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = RouteAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        annotationView.canShowCallout = true
        annotationView.calloutOffset = CGPoint(x: -5, y: 5)
        
        return annotationView
    }
    
    public func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        SVProgressHUD.showWithStatus("定位中")
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.pinView.center = CGPointMake(self!.pinView.center.x, self!.pinView.center.y - 10)
            })
    }
    
    public func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let circle = MKCircleRenderer(overlay: overlay)
        circle.fillColor = UIColor(red: 0.0, green: 0.0, blue: 1, alpha: 0.2)
        return circle
        
    }
    
    public func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.pinView.center = CGPointMake(self!.pinView.center.x, self!.pinView.center.y + 10)
            })
        
        self.currentLocation = mapView.region.center
        
        let params:Dictionary<String,AnyObject> = [
            "lat":self.currentLocation.latitude,
            "lng":self.currentLocation.longitude
        ]
        let opt = try! HTTP.GET(UIConstant.AppDomain+"location/pois", parameters: params)
        opt.start { response in
            if response.error == nil {
                let json = JSON(data:response.data)
                self.datas = [JSON]()
                for _data in json["pois"] {
                    self.datas.append(_data.1)
                }
                dispatch_sync(dispatch_get_main_queue()) {
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
               
            }
            
        }
              
        
        
    }
    public func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if self.mainMapView.overlays.count == 0 {
            let c = MKCircle(centerCoordinate: userLocation.coordinate, radius: 50 as CLLocationDistance)
            self.mainMapView.addOverlay(c)
            
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 250,250)
            self.mainMapView!.setRegion(region, animated: true)
        }
        
        self.userLocation = userLocation.coordinate
        self.currentLocation = userLocation.coordinate
        
        //self.mainMapView.convertCoordinate(userLocation.coordinate, toPointToView: pinView)
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let data = self.datas[indexPath.row]
        self.data = data
        completionCallback?(self)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("location_cell") as! LocationCell
        let data = self.datas[indexPath.row]
        cell.imageView?.image = UIImage()
        cell.imageView?.highlightedImage =  UIImage(named: "icon_lbs_access")
        cell.name.text = data["name"].string!
        cell.address.text = data["addr"].string!
        return cell
    }
}

class LocationCell:UITableViewCell {
    var name:UILabel!
    var address:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIColor.whiteColor()
        
        self.setupViews()
    }
    required init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has nont been implemented")
    }
    
    func setupViews() {
        self.name = UILabel()
        self.name.translatesAutoresizingMaskIntoConstraints = false
        self.name.font = UIFont.boldSystemFontOfSize(16)
        self.name.textColor = UIColor(rgba: "#333")
        
        self.contentView.addSubview(self.name)
        
        self.name.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(8)
            make.top.equalTo(8)
        }
        
        self.address = UILabel()
        self.address.translatesAutoresizingMaskIntoConstraints = false
        self.address.font = UIFont.systemFontOfSize(12)
        self.address.textColor = UIColor(rgba: "#999")
        
        self.contentView.addSubview(self.address)
        
        self.address.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(8)
            make.top.equalTo(self.name.snp_bottom).offset(5)
            make.bottom.equalTo(-8)
        }
    }
}

class RouteAnnotationView: MKAnnotationView {
    // Required for MKAnnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when drawing the AttractionAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = UIImage(named: "icon_lbs_location")
    }
}




